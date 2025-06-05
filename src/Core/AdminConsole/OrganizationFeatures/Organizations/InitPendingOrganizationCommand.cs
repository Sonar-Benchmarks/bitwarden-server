﻿using Bit.Core.AdminConsole.Enums;
using Bit.Core.AdminConsole.OrganizationFeatures.Policies;
using Bit.Core.AdminConsole.OrganizationFeatures.Policies.PolicyRequirements;
using Bit.Core.AdminConsole.Services;
using Bit.Core.Auth.Models.Business.Tokenables;
using Bit.Core.Entities;
using Bit.Core.Enums;
using Bit.Core.Exceptions;
using Bit.Core.Models.Data;
using Bit.Core.OrganizationFeatures.OrganizationUsers.Interfaces;
using Bit.Core.Repositories;
using Bit.Core.Services;
using Bit.Core.Tokens;

namespace Bit.Core.AdminConsole.OrganizationFeatures.OrganizationUsers;

public class InitPendingOrganizationCommand : IInitPendingOrganizationCommand
{

    private readonly IOrganizationService _organizationService;
    private readonly ICollectionRepository _collectionRepository;
    private readonly IOrganizationRepository _organizationRepository;
    private readonly IDataProtectorTokenFactory<OrgUserInviteTokenable> _orgUserInviteTokenDataFactory;
    private readonly IPolicyService _policyService;
    private readonly IOrganizationUserRepository _organizationUserRepository;
    private readonly IFeatureService _featureService;
    private readonly IPolicyRequirementQuery _policyRequirementQuery;

    public InitPendingOrganizationCommand(
            IOrganizationService organizationService,
            ICollectionRepository collectionRepository,
            IOrganizationRepository organizationRepository,
            IDataProtectorTokenFactory<OrgUserInviteTokenable> orgUserInviteTokenDataFactory,
            IPolicyService policyService,
            IOrganizationUserRepository organizationUserRepository,
            IFeatureService featureService,
            IPolicyRequirementQuery policyRequirementQuery
            )
    {
        _organizationService = organizationService;
        _collectionRepository = collectionRepository;
        _organizationRepository = organizationRepository;
        _orgUserInviteTokenDataFactory = orgUserInviteTokenDataFactory;
        _policyService = policyService;
        _organizationUserRepository = organizationUserRepository;
        _featureService = featureService;
        _policyRequirementQuery = policyRequirementQuery;
    }

    public async Task InitPendingOrganizationAsync(User user, Guid organizationId, Guid organizationUserId, string publicKey, string privateKey, string collectionName, string emailToken)
    {
        await ValidateSignUpPoliciesAsync(user.Id);

        var orgUser = await _organizationUserRepository.GetByIdAsync(organizationUserId);
        if (orgUser == null)
        {
            throw new BadRequestException("User invalid.");
        }

        var tokenValid = ValidateInviteToken(orgUser, user, emailToken);

        if (!tokenValid)
        {
            throw new BadRequestException("Invalid token");
        }

        var org = await _organizationRepository.GetByIdAsync(organizationId);

        if (org.Enabled)
        {
            throw new BadRequestException("Organization is already enabled.");
        }

        if (org.Status != OrganizationStatusType.Pending)
        {
            throw new BadRequestException("Organization is not on a Pending status.");
        }

        if (!string.IsNullOrEmpty(org.PublicKey))
        {
            throw new BadRequestException("Organization already has a Public Key.");
        }

        if (!string.IsNullOrEmpty(org.PrivateKey))
        {
            throw new BadRequestException("Organization already has a Private Key.");
        }

        org.Enabled = true;
        org.Status = OrganizationStatusType.Created;
        org.PublicKey = publicKey;
        org.PrivateKey = privateKey;

        await _organizationService.UpdateAsync(org);

        if (!string.IsNullOrWhiteSpace(collectionName))
        {
            // give the owner Can Manage access over the default collection
            List<CollectionAccessSelection> defaultOwnerAccess =
                [new CollectionAccessSelection { Id = orgUser.Id, HidePasswords = false, ReadOnly = false, Manage = true }];

            var defaultCollection = new Collection
            {
                Name = collectionName,
                OrganizationId = org.Id
            };
            await _collectionRepository.CreateAsync(defaultCollection, null, defaultOwnerAccess);
        }
    }

    private async Task ValidateSignUpPoliciesAsync(Guid ownerUserId)
    {
        var blockedBySingleOrganizationPolicy = _featureService.IsEnabled(FeatureFlagKeys.PolicyRequirements)
            ? !(await _policyRequirementQuery.GetAsync<SingleOrganizationPolicyRequirement>(ownerUserId)).CanCreateOrganization()
            : await _policyService.AnyPoliciesApplicableToUserAsync(ownerUserId, PolicyType.SingleOrg);

        if (blockedBySingleOrganizationPolicy)
        {
            throw new BadRequestException("You may not create an organization. You belong to an organization " +
                "which has a policy that prohibits you from being a member of any other organization.");
        }
    }

    private bool ValidateInviteToken(OrganizationUser orgUser, User user, string emailToken)
    {
        var tokenValid = OrgUserInviteTokenable.ValidateOrgUserInviteStringToken(
            _orgUserInviteTokenDataFactory, emailToken, orgUser);

        return tokenValid;
    }
}

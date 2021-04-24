/**
 * @author Mateusz Przywara
 * @date   2016-08-05
 * @description BTN_ConstantRepo Class provides Contants for BriteCRM/BriteRM project
 */
public with sharing class BTN_ConstantRepo {
    // TODO: add missing stages and sort by category
    // TODO Convention about names
    // TODO THE MOST GENERAL ON THE LEFT!
    // TODO So for example CASE_EXTERNAL_ONBOARDING_RECORDTYPE -> RECORDTYPE_NAME_CASE_EXTERNAL
    public static final String ADMIN_EMAIL = 'mateusz.przywara@britenet.com.pl';

    //TODO  to delete.
    public static final String EMAIL_TEMPLATE_RR_TO_HR = 'BTN_CandidateRequest';
    public static final String BRITENET_MAIL_SUFFIX = '@britenet.com';
    public static final String BRITENET_MAIL_SUFFIX_PL = '@britenet.com.pl';
    public static final String BRITENET_ACCOUNT_NAME = 'Britenet Sp. z o.o.';
    public static final String ACCOUNT_PRIVATE_NAME = 'PrivateClient';
    public static final String ACCOUNT_PUBLIC_NAME = 'PublicClient';
    public static final String ACCOUNT_PRIVATE_SECTOR = 'PrivateSector';
    public static final String ACCOUNT_BRITENET_RECORD_TYPE = 'Britenet';
    public static final String ACCOUNT_PUBLIC_RECORD_TYPE = 'PublicSector';
    public static final String INTERNAL_CONTACT_RECORDTYPE_NAME = 'Internal';
    public static final String EXTERNAL_CONTACT_RECORDTYPE_NAME = 'Recruit';
    public static final String BUSINESS_CONTACT_RECORDTYPE_NAME = 'Business';
    public static final String UTF_ENCODING = 'UTF-8';
    public static final String DEV_ENVIRONMENT = 'dev';
    public static final String INT_ENVIRONMENT = 'int';
    public static final String UAT_ENVIRONMENT = 'uat';
    public static final String BSS_JOB_NAME = 'Pro Sync Internal BriteNet Contacts With BS';
    public static final String BSS_JOB_CRON = '0 0 4 * * ?';
    public static final String SANDBOX_POSTREFRESH_MANUAL_STEPS = 'Sandbox_Post_Copy_Manual_Steps';
    public static final String SANDBOX_POSTREFRESH_DEFAULT_ADMIN = 'PostRefresh.DefaultAdmins';
    public static final String SANDBOX_POSTREFRESH_ACTIVATED_ADMINS = 'PostRefresh.ActivatedAdmins';

    public static final String URL_PARAM_NOOVERRIDE = 'nooverride';
    public static final String URL_PARAM_RECORDTYPE_ID = 'RecordType';
    public static final String NOOVERRIDE = '1';
    public static final String URL_PARAM_RETURL = 'retURL';
    public static final String NEW_OPPORTUNITY_TASK_PRIORITY_NORMAL = 'Normal';
    public static final String NEW_OPPORTUNITY_TASK_STATUS_OPEN = 'Open';
    public static final String NEW_OPPORTUNITY_AUTO_GENERATED_SUFFIX = 'auto generated';
    public static final String TM_OPPORTUNITY_RECORDTYPE_NAME = 'TimeMaterial';
    public static final String FP_OPPORTUNITY_RECORDTYPE_NAME = 'FixedPrice';

    public static final String CANDIDATE_SOURCE_HUMAN_RESOURCES = 'Human Resources';
    public static final String CANDIDATE_SITE_NAME = 'Britenet_CV';
    public static final String URL_PARAM_CANDIDATE_ID = 'CandidateId';
    public static final String URL_PARAM_CONTACT_ID = 'ContactId';
    public static final String CANDIDATE_STATUS_OPEN = 'Open';
    public static final String CANDIDATE_STATUS_REJECTED = 'Rejected';
    public static final String CANDIDATE_STATUS_APPROVED = 'Approved';
    public static final String CANDIDATE_STATUS_CONTRACT_SIGNED = 'Contract signed';
    public static final String CANDIDATE_STATUS_CONTRACT_SIGNED_WITH_DIFFERENT_EXTERNAL = 'Contract signed with different external';
    public static final String CANDIDATE_STATUS_INTERVIEW_IN_PROGRESS = 'Interview-in-progress';
    public static final String CANDIDATE_STATUS_SUBMITTED_TO_EXTERNAL = 'Submitted to external';
    public static final String RECORDTYPE_NAME_CANDIDATE_INTERNAL = 'Internal';
    public static final String RECORDTYPE_NAME_CANDIDATE_EXTERNAL = 'External';

    public static final String RESOURCE_REQUEST_URL_PARAMETER_NAME = 'request';
    public static final String RESOURCE_REQUEST_RECORD_TYPE_MANUAL = 'Manual';
    public static final String RESOURCE_REQUEST_RECORD_TYPE_AUTO = 'Auto';
    public static final String REQUESTOR_TOKEN_PARAMETER_NAME = 'token';
    public static final String BILLING_TYPE_UNBILLABLE = 'Unbillable';
    public static final String CONTACT_PARAMETER_NAME = 'contact';
    public static final String RESOURCE_MANAGER_PROFILE_NAME = 'BTN Resource Manager';
    public static final String SALES_PROFILE_NAME = 'BTN Sales User';
    public static final String SALES_ROLE_NAME = 'Sales';
    public static final String ADMIN_PROFILE_NAME = 'System Administrator';
    public static final String BTN_ADMIN_ROLE_NAME = 'Admin';
    public static final String EXTERNAL_RESOURCE_REQUEST_PROFILE_NAME = 'Britenet resource request Profile';
    public static final String EXTERNAL_CV_PROFILE_NAME = 'Britenet CV Profile';
    public static final String PERM_SET_NAME_RESOURCE_REQUESTOR = 'BTN_Resource_Requestor';
    public static final String PERM_SET_NAME_HR = 'BTN_Human_Resources';
    public static final String PERM_SET_NAME_HR_MANAGER = 'BTN_HumanResourcesManager';
    public static final String PERM_SET_NAME_TECHNICAL_LEADER = 'BTN_TechnicalLeader';
    public static final String QUEUE_HUMAN_RESOURCES = 'BTN_HumanResources';
    public static final String PROFILE_NAME_HR = 'HR';
    public static final String ROLE_NAME_HR = 'HR';
    public static final String RM_USERNAME = 'RM';
    public static final String PROFILE_NAME_COMMUNITY = 'BTN Community user Plus';
    public static final String LICENSE_COMMUNITY = 'Customer Community';
    public static final String SITE_USERS_PUBLIC_GROUP_NAME = 'PublicUsers';
    public static final String SUCCESS_MESSAGE = 'success';
    public static final String FAIL_MESSAGE = 'failure';
    public static final String LINKEDIN_API_NAME = 'linkedInApi';
    public static final String TASK_SUBJECT = 'Wysłać CV do klienta';
    public static final String TASK_STATUS_COMPLETED = 'Completed';
    public static final String OPPORTUNITY_STAGE_NAME_IN_PROGRESS = 'In progress';
    public static final String OPPORTUNITY_STAGE_NAME_DRAFT = 'Draft';
    public static final String OPPORTUNITY_STAGE_NAME_APPROVED = 'Approved';
    public static final String OPPORTUNITY_STAGE_NAME_CLOSED_LOST = 'Closed Lost';
    public static final String OPPORTUNITY_STAGE_NAME_CLOSED_WON = 'Closed Won';
    public static final String HOST_PARAMETER_NAME = 'Host';
    //TODO check if anyone is using this Const
    public static final String URL_PARAM_CANDIDATE_REQUEST_ID = 'candidateRequest';

    public static final String RESOURCE_MANAGERS_GROUP_NAME = 'Resource_Managers';
    public static final String HUMAN_RESOURCES_GROUP_NAME = 'All HR';
    
    //google integration
    public static final string OAUTH_TOKEN_URL='https://accounts.google.com/o/oauth2/token';
    public static final string OAUTH_CODE_END_POINT_URL='https://accounts.google.com/o/oauth2/auth';    
    public static final string GRANT_TYPE_AUTH_CODE='grant_type=authorization_code';
    public static final string GRANT_TYPE_REFRESH_TOKEN='grant_type=refresh_token';
    public static final string SCOPE = 'https://spreadsheets.google.com/feeds https://docs.google.com/feeds https://www.google.com/m8/feeds https://www.googleapis.com/auth/calendar';
    public static final string STATE='/profile';
    public static final string APPROVAL_PROMPT='force';
    public static final String CUSTOM_SETTING_KEY_DEF_CONTACT_OWNER = 'Default Contact Owner';
    public static final String CUSTOM_SETTING_KEY_GOOGLE_CLIENT_ID = 'GoogleClientId';
    public static final String CUSTOM_SETTING_KEY_GOOGLE_SECRET = 'GoogleClientSecret';
    public static final String CUSTOM_SETTING_KEY_GOOGLE_REDIRECT = 'GoogleAuthRedirectUrl';
    public static final String CUSTOM_SETTING_KEY_GOOGLE_REDIRECT_COMMUNITY = 'GoogleAuthRedirectUrlCommunity';
    public static final String CUSTOM_SETTING_DEFAULT_CONTRACT_COMPANY = 'Default Contract Company';

    // Case RecordType Developer Names
    public static final String CASE_EXTERNAL_ONBOARDING_RECORDTYPE = 'ExternalOnboarding';
    public static final String CASE_EXTERNAL_OFFBOARDING_RECORDTYPE = 'ExternalOffboarding';
    public static final String CASE_INTERNAL_ONBOARDING_RECORDTYPE = 'InternalOnboarding';
    public static final String CASE_INTERNAL_OFFBOARDING_RECORDTYPE = 'InternalOffboarding';
    public static final String CASE_STATUS_REJECTED = 'Rejected';
    public static final String CASE_STATUS_APPROVED = 'Approved';
    public static final String CASE_STATUS_SUBMITTED = 'Submitted';
    public static final String CASE_STATUS_OPEN = 'Open';
    public static final String CASE_CONTRACT_TYPE_B2B = 'B2B';
    public static final String CASE_CONTRACT_TYPE_UOP = 'Umowa o Pracę';

    public static final String PROJECT_TYPE_UNB = 'UNB';
    public static final String PROJECT_TYPE_TS = 'TS';
    public static final String PROJECT_TYPE_FIX = 'FIX';
    public static final String PROJECT_TYPE_SUP = 'SUP';
    public static final String PROJECT_TYPE_LM = 'LM';

    public static final String EQUIPMENT_COMPANY_DEFAULT = 'Britenet';

    public static final String FINANCE_ACCOUNT_TYPE_COST = 'Cost';
    public static final String FINANCE_ACCOUNT_TYPE_INCOME = 'Income';
    public static final String FINANCE_ACCOUNT_PROJECT_TYPE_CODE_NAME_UNB = 'UNB';
    public static final String FINANCE_ACCOUNT_PROJECT_TYPE_CODE_NAME_TS = 'T&M';
    public static final String FINANCE_ACCOUNT_PROJECT_TYPE_CODE_NAME_FIX = 'Fixy';
    public static final String FINANCE_ACCOUNT_PROJECT_TYPE_CODE_NAME_SUP = 'Support';
    public static final String FINANCE_ACCOUNT_PROJECT_TYPE_CODE_NAME_LM = 'LM';
    public static final Map<String, String> FINANCE_ACCOUNT_PROJECT_TYPE_CODE_NAME_BY_PROJECT_TYPE = new Map<String, String> {
            BTN_ConstantRepo.PROJECT_TYPE_UNB => BTN_ConstantRepo.FINANCE_ACCOUNT_PROJECT_TYPE_CODE_NAME_UNB,
            BTN_ConstantRepo.PROJECT_TYPE_TS => BTN_ConstantRepo.FINANCE_ACCOUNT_PROJECT_TYPE_CODE_NAME_TS,
            BTN_ConstantRepo.PROJECT_TYPE_FIX => BTN_ConstantRepo.FINANCE_ACCOUNT_PROJECT_TYPE_CODE_NAME_FIX,
            BTN_ConstantRepo.PROJECT_TYPE_SUP => BTN_ConstantRepo.FINANCE_ACCOUNT_PROJECT_TYPE_CODE_NAME_SUP,
            BTN_ConstantRepo.PROJECT_TYPE_LM => BTN_ConstantRepo.FINANCE_ACCOUNT_PROJECT_TYPE_CODE_NAME_LM
    };

    public static final String COST_TYPE_PROJECT = 'Project_Costs';
    public static final String COST_TYPE_DEPARTMENT = 'Department_Costs';
    public static final String COST_TYPE_DELEGATION = 'Delegation_Costs';
    public static final String COST_TYPE_ADMINISTRATIVE_SERVICES = 'Administrative_Services';
    public static final String COST_TYPE_EMPLOYEE = 'Employee_Costs';

    public static final String CITY_LOCATION_LUBLIN = 'Lublin';
    public static final String CITY_LOCATION_WARSAW = 'Warszawa';
    public static final String CITY_LOCATION_POZNAN = 'Poznań';
    public static final String CITY_LOCATION_KIELCE = 'Kielce';

    public static final String OFFICE_LOCATION_MORWOWA = 'Lublin Morwowa';
    public static final String OFFICE_LOCATION_HAMLETA = 'Lublin Hamleta';
    public static final String OFFICE_LOCATION_WOLOSKA = 'Warszawa Wołoska';
    public static final String OFFICE_LOCATION_BUKOWINSKA = 'Warszawa Bukowińska';
    public static final String OFFICE_LOCATION_IX_WIEKOW = 'Kielce IX Wieków';
    public static final String OFFICE_LOCATION_SZYPERSKA = 'Poznań Szyperska';

    public static final String URL_PARAM_CUSTOMEVENT_TYPE = 'Type';

    // old version support <2.3
    public static final String orgSuffix = '.crm.test';
    public static final String linkedApiRecordName = 'linkedInApi';
    public static final String newOpportunityTaskSubjectSuffix = 'auto generated';
    public static final String googleCalScopes = 'https://www.googleapis.com/auth/calendar';
    public static final String googleCalCallbackPage = '/apex/gAPI_OAuth_Callback';
}
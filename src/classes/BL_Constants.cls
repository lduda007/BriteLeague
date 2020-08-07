public class BL_Constants {

    // TODO: 1) Rename to Competition 2) Refactor status values
    public static final String LEAGUE_STATUS_ASSEMBLING_TEAMS = 'Assembling teams';
    public static final String LEAGUE_STATUS_STARTED = 'Started';
    public static final String LEAGUE_STATUS_FINISHED = 'Finished';

    public static final Set<String> LEAGUE_STARTED_STATUSES = new Set<String>{
            LEAGUE_STATUS_STARTED, LEAGUE_STATUS_FINISHED
    };

    public static final String LEAGUE_RT_LEAGUE = 'League';
    public static final String LEAGUE_RT_CUP = 'Cup';
    public static final String LEAGUE_RT_BATTLE_ROYALE = 'Battle_Royale';

    public static final String TEAM_RT_CLASSIC = 'Classic';
    public static final String TEAM_RT_BATTLE_ROYALE = 'Battle_Royale';

    public static final String ICON_STANDARD_AVATAR = 'standard:avatar';
    public static final String ICON_STANDARD_CUSTOMERS = 'standard:customers';
    public static final String ICON_STANDARD_HOUSEHOLD = 'standard:household';
}
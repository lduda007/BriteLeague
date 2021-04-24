public with sharing class BTN_JiraController {

	public static final Integer PAGE_SIZE = 5;

	public String summary {get;set;}
	public String description {get;set;}
	public String priority {get;set;}
	public String issueType {get;set;}
	public String body {get;set;}
	public String issueKey {get;set;}
	public Integer page {get;set;}
	public Integer total {get;set;}

	public List<SelectOption> typesOptions {
		get {
			List<SelectOption> options = initBaseOptions();
			if (issueCreateMeta != null) {
				for (JiraDTO.ProjectDTO project : issueCreateMeta.projects) {
					for (JiraDTO.IssueTypeDTO type : project.issuetypes) {
						options.add(new SelectOption(type.id, type.name));
					}
				}
			}
			return options;
		}

		private set;
	}

	public List<SelectOption> priorityOptions {
		get {
			List<SelectOption> options = initBaseOptions();
			if (priorities != null) {
				for (JiraDTO.PriorityDTO priority : priorities) {
					options.add(new SelectOption(priority.id, priority.name));
				}
			}
			return options;
		}

		private set;
	}

	public JiraDTO.IssueDTO[] issues {
		get {
			if (service != null) {
				try {
					JiraDTO.SearchResultDTO result = service.getAllIssues(page * PAGE_SIZE, PAGE_SIZE);
					this.total = result.total;
					return result.issues;
				} catch (JiraApiService.JiraException ex) {
					processServiceErrors(ex);
				} catch (Exception ex) {
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, ex.getMessage()));
				}
			}

			this.total = 0;
			return new List<JiraDTO.IssueDTO>();
		}

		private set;
	}

	public JiraDTO.IssueDTO issue {
		get {
			if (service != null && String.isNotBlank(issueKey)) {
				return service.getIssue(issueKey);
			}
			return null;
		}

		private set;
	}

	public String[] errorMessages {
		get {
			String[] res = fetchMessagesBySeverity(ApexPages.Severity.FATAL);
			return res.isEmpty() ? null : res;
		}

		private set;
	}

	public String[] infoMessages {
		get {
			String[] res = fetchMessagesBySeverity(ApexPages.Severity.INFO);
			return res.isEmpty() ? null : res;
		}

		private set;
	}

	private JiraApiService service;
	private JiraDTO.CreateMetaDTO issueCreateMeta;
	private JiraDTO.PriorityDTO[] priorities;

	public BTN_JiraController() {
		page = 0;

		try {
			service = new JiraApiService();
		} catch (Exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, ex.getMessage()));
			return;
		}

		try {
			issueCreateMeta = service.getIssueCreateMeta();
			priorities = service.getAllPriorities();
		} catch (JiraApiService.JiraException ex) {
			processServiceErrors(ex);
		} catch (Exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, ex.getMessage()));
		}
	}

	public PageReference createIssue() {
		String key = null;
		try {
			key = service.createIssue(this.summary, this.description, this.priority, this.issueType);
		} catch (JiraApiService.JiraException ex) {
			processServiceErrors(ex);
		} catch (Exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, ex.getMessage()));
		}

		if (String.isNotBlank(key)) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, key + ': issue created.'));
		}

		return null;
	}

	public PageReference addComment() {
		String id = null;
		try {
			id = service.addComment(this.body, this.issue.key);
		} catch (JiraApiService.JiraException ex) {
			processServiceErrors(ex);
		} catch (Exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, ex.getMessage()));
		}

		if (String.isNotBlank(id)) {
			this.body = '';
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Comment was created'));
		}

		return null;
	}

	public PageReference loadJira() {
		return null;
	}

	public PageReference nextPage() {
		this.page++;

		return null;
	}

	public PageReference previousPage() {
		this.page--;

		return null;
	}

	private void processServiceErrors(JiraApiService.JiraException ex) {
		for (String msg : ex.getErrorMessages()) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, msg));
		}

		String issueTypeError = ex.getIssueTypeError();
		if (String.isNotBlank(issueTypeError)) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, issueTypeError));
		}

		String statusError = ex.getStatusError();
		if (String.isNotBlank(statusError)) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, statusError));
		}

		String projectError = ex.getProjectError();
		if (String.isNotBlank(projectError)) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, projectError));
		}

		String standardError = ex.getMessage();
		if (String.isNotBlank(standardError)) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, standardError));
		}
	}

	private List<SelectOption> initBaseOptions() {
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('', Label.None));
		return options;
	}

	private String[] fetchMessagesBySeverity(ApexPages.Severity severity) {
		String[] msgs = new List<String>();
		for (ApexPages.Message msg : ApexPages.getMessages()) {
			if (msg.getSeverity() == severity) {
				msgs.add(msg.getSummary());
			}
		}
		return msgs;
	}


}
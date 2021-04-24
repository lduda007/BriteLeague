global class JiraApiService {

	private String url;
	private String pass;
	private String project;

	public JiraApiService() {
		this.project = BTN_Utils.getBTNPropertyValue('Jira.Project');

		List<ConnectionProperty__c> connections = [
				SELECT Username__c, Password__c, Endpoint__c
				FROM ConnectionProperty__c
				WHERE Name = 'Jira'
		];

		if (connections.size() == 1) {
			ConnectionProperty__c con = connections.get(0);
			this.url = con.Endpoint__c;

			String credentails = con.Username__c + ':' + con.Password__c;
			this.pass = EncodingUtil.base64Encode(Blob.valueOf(credentails));
		} else {
			throw new JiraException('Jira connection need proper configuration.');
		}
	}

	public JiraDTO.CreateMetaDTO getIssueCreateMeta() {
		String jsonString = new HttpRequestBuilder(url + 'issue/createmeta')
			.header('Authorization', 'Basic ' + pass)
			.param('projectKeys', project)
			.get();

		checkErrors(jsonString);

		return (JiraDTO.CreateMetaDTO) JSON.deserialize(jsonString, JiraDTO.CreateMetaDTO.class);
	}

	public JiraDTO.IssueDTO[] getAllIssues() {
		String jsonString = new HttpRequestBuilder(url + 'search')
			.header('Authorization', 'Basic ' + pass)
			.param('maxResults', '10')
			.param('jql', 'project=' + project)
			.get();

		checkErrors(jsonString);

		JiraDTO.SearchResultDTO dto = (JiraDTO.SearchResultDTO) JSON.deserialize(jsonString, JiraDTO.SearchResultDTO.class);

		return dto.issues;
	}

	public JiraDTO.SearchResultDTO getAllIssues(Integer startAt, Integer maxResults) {
		String jsonString = new HttpRequestBuilder(url + 'search')
			.header('Authorization', 'Basic ' + pass)
			.param('maxResults', String.valueOf(maxResults))
			.param('startAt', String.valueOf(startAt))
			.param('jql', 'project=' + project)
			.get();

		checkErrors(jsonString);

		JiraDTO.SearchResultDTO dto = (JiraDTO.SearchResultDTO) JSON.deserialize(jsonString, JiraDTO.SearchResultDTO.class);

		return dto;
	}

	public JiraDTO.IssueDTO getIssue(String key) {
		String jsonString = new HttpRequestBuilder(url + 'issue/' + key)
			.header('Authorization', 'Basic ' + pass)
			.get();

		checkErrors(jsonString);

		return (JiraDTO.IssueDTO) JSON.deserialize(jsonString, JiraDTO.IssueDTO.class);
	}

	public String createIssue(String summary, String description, String priority, String issueType) {
		JiraDTO.IssueDTO issue = prepareIssueDTO(summary, description, priority, issueType, project);
		String jsonString = JSON.serialize(issue, true);

		String response = new HttpRequestBuilder(url + 'issue')
			.header('Authorization', 'Basic ' + pass)
			.header('Content-Type', 'application/json; charset=UTF-8')
			.body(jsonString)
			.post();

		checkErrors(response);

		JiraDTO.IssueDTO createdIssue = null;
		if (String.isNotBlank(response)) {
			createdIssue = (JiraDTO.IssueDTO) JSON.deserialize(response, JiraDTO.IssueDTO.class);
		}

		return createdIssue != null ? createdIssue.key : null;
	}

	public JiraDTO.CommentItemDTO[] getComments(String issueId) {
		String jsonString = new HttpRequestBuilder(url + 'issue/' + issueId + '/comment')
			.header('Authorization', 'Basic ' + pass)
			.get();

		checkErrors(jsonString);

		JiraDTO.CommentDTO commentDTO = (JiraDTO.CommentDTO) JSON.deserialize(jsonString, JiraDTO.CommentDTO.class);

		return commentDTO.comments;
	}

	public String addComment(String body, String issueId) {
		JiraDTO.CommentItemDTO comment = prepareCommentDTO(body);
		String jsonString = JSON.serialize(comment, true);

		String response = new HttpRequestBuilder(url + 'issue/' + issueId + '/comment')
			.header('Authorization', 'Basic ' + pass)
			.header('Content-Type', 'application/json; charset=UTF-8')
			.body(jsonString)
			.post();

		checkErrors(response);

		JiraDTO.CommentItemDTO createdComment = null;
		if (String.isNotBlank(response)) {
			createdComment = (JiraDTO.CommentItemDTO) JSON.deserialize(response, JiraDTO.CommentItemDTO.class);
		}

		return createdComment != null ? createdComment.id : null;
	}

	public void updateComment(String commentId, String issueId, String body) {
		JiraDTO.CommentItemDTO comment = prepareCommentDTO(body);
		String jsonString = JSON.serialize(comment, true);

		String response = new HttpRequestBuilder(url + 'issue/' + issueId + '/comment/' + commentId)
			.header('Authorization', 'Basic ' + pass)
			.header('Content-Type', 'application/json; charset=UTF-8')
			.body(jsonString)
			.put();

		checkErrors(response);
	}

	public void deleteComment(String issueId, String commentId) {
		String response = new HttpRequestBuilder(url + 'issue/' + issueId + '/comment/' + commentId)
			.header('Authorization', 'Basic ' + pass)
			.del();

		checkErrors(response);
	}

	public JiraDTO.PriorityDTO[] getAllPriorities() {
		String jsonString = new HttpRequestBuilder(url + 'priority')
			.header('Authorization', 'Basic ' + pass)
			.get();

		checkErrors(jsonString);

		return (List<JiraDTO.PriorityDTO>) JSON.deserialize(jsonString, List<JiraDTO.PriorityDTO>.class);
	}

	private void checkErrors(String jsonString) {
		if (jsonString.contains('Unauthorized')) {
			throw new JiraException('Unauthorized: wrong Jira credentials.');
		}
		if (jsonString.contains('errorMessages') || jsonString.contains('errors')) {
			JiraDTO.ErrorDTO dto = (JiraDTO.ErrorDTO) JSON.deserialize(jsonString, JiraDTO.ErrorDTO.class);
			throw new JiraException(dto);
		}
	}

	private JiraDTO.IssueDTO prepareIssueDTO(String summary, String description, String priority, String issueType, String projectId) {
		JiraDTO.IssueDTO issue = new JiraDTO.IssueDTO();

		JiraDTO.FieldsDTO fields = new JiraDTO.FieldsDTO();

		fields.project = new JiraDTO.ProjectDTO();
		fields.project.key = projectId;

		fields.issuetype = new JiraDTO.IssueTypeDTO();
		fields.issuetype.id = issueType;

		fields.priority = new JiraDTO.PriorityDTO();
		fields.priority.id = priority;

		fields.summary = summary;
		fields.description = description;

		issue.fields = fields;

		return issue;
	}

	private JiraDTO.CommentItemDTO prepareCommentDTO(String body) {
		JiraDTO.CommentItemDTO comment = new JiraDTO.CommentItemDTO();
		comment.body = body;

		return comment;
	}

	public class JiraException extends Exception {

		private JiraDTO.ErrorDTO error;

		public JiraException(JiraDTO.ErrorDTO error) {
			this.error = error;
		}

		public List<String> getErrorMessages() {
			return (this.error != null && this.error.errorMessages != null) ? this.error.errorMessages : new List<String>();
		}

		public String getProjectError() {
			return (this.error != null && this.error.errors != null) ? this.error.errors.project : null;
		}

		public String getStatusError() {
			return (this.error != null && this.error.errors != null) ? this.error.errors.status : null;
		}

		public String getIssueTypeError() {
			return (this.error != null && this.error.errors != null) ? this.error.errors.issuetype : null;
		}

	}

}
global class JiraDTO {

	public class ErrorDTO {
		public List<String> errorMessages {get; set;}
		public ErrorsDTO errors {get; set;}
	}

	public class ErrorsDTO {
		public String project {get; set;}
		public String status {get; set;}
		public String issuetype {get; set;}
	}

	public class SearchResultDTO {
		public Integer startAt {get; set;}
		public Integer maxResults {get; set;}
		public Integer total {get; set;}
		public IssueDTO[] issues {get; set;}
	}

	public class IssueDTO {
		public String id {get; set;}
		public String key {get; set;}
		public Datetime created {get; set;}
		public Datetime updated {get; set;}
		public FieldsDTO fields {get; set;}
	}

	public class FieldsDTO {
		public String summary {get; set;}
		public String description {get; set;}
		public String[] labels {get;set;}
		public AuthorDTO assignee {get; set;}
		public AuthorDTO creator {get; set;}
		public AuthorDTO reporter {get; set;}
		public CommentDTO comment {get; set;}
		public IssueTypeDTO issuetype {get; set;}
		public PriorityDTO priority {get; set;}
		public StatusDTO status {get; set;}
		public ProjectDTO project {get; set;}
	}

	public class CommentDTO {
		public Integer maxResults {get; set;}
		public Integer total {get; set;}
		public Integer startAt {get; set;}
		public CommentItemDTO[] comments {get; set;}
	}

	public class CommentItemDTO {
		public String id {get; set;}
		public String body {get; set;}
		public AuthorDTO author {get; set;}
		public AuthorDTO updateAuthor {get; set;}
		public Datetime created {get; set;}
		public Datetime updated {get; set;}
	}

	public class AuthorDTO {
		public String name {get; set;}
		public String displayName {get; set;}
		public String emailAddress {get; set;}
		public Boolean active {get; set;}
	}

	public class IssueTypeDTO {
		public String id {get; set;}
		public String name {get; set;}
		public String description {get; set;}
		public String iconUrl {get; set;}
		public Boolean subtask {get; set;}
		public List<StatusDTO> statuses {get; set;}
	}

	public class PriorityDTO {
		public String id {get; set;}
		public String name {get; set;}
		public String statusColor {get; set;}
		public String iconUrl {get; set;}
	}

	public class StatusDTO {
		public String id {get; set;}
		public String name {get; set;}
		public String description {get; set;}
		public String iconUrl {get; set;}
	}

	public class ProjectDTO {
		public String id {get; set;}
		public String key {get; set;}
		public String name {get; set;}
		public List<IssueTypeDTO> issuetypes {get; set;}
	}

	public class CreateMetaDTO {
		public List<ProjectDTO> projects {get; set;}
	}

}
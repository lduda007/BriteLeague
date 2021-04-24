public class BTN_Sheet {
    public String id;
    public String name;
    public Integer version;
    public Integer totalRowCount;
    public String accessLevel;
    public List<String> effectiveAttachmentOptions;
    public Boolean ganttEnabled;
    public Boolean dependenciesEnabled;
    public Boolean resourceManagementEnabled;
    public Boolean cellImageUploadEnabled;
    public String permalink;
    public Datetime createdAt;
    public Datetime modifiedAt;
    public List<Column> columns;
    public List<Row> rows;
    public Boolean readOnly;

    /**
     * Opportunity field representation
     */
    public class Column {
        public String id;
        public Integer index;
        public String title;
        public String type;
        public List<String> options;
        public Integer width;
        public Boolean primary;
        public Boolean hidden;
    }

    /**
     * Opportunity representation
     */
    public class Row {
        public String id;
        public Integer rowNumber;
        public String parentId;
        public String siblingId;
        public Boolean locked;
        public Boolean expanded;
        public Datetime createdAt;
        public Datetime modifiedAt;
        public List<Cell> cells;
    }

    /**
     * Opportunity field value representation
     */
    public class Cell {
        public String columnId;
        public String value;
        public String displayValue;
        public String formula;
        public String format;

    }

	/**
     * Attachment with URL
     */
    class RowAttachment {
        public String id;
        public String name;
        public String url;
        public String attachmentType;
        public String attachmentSubType;
        public Datetime createdAt;
        public Datetime modifiedAt;
    }
}
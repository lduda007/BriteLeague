public class BTN_UserSheets {
    public Integer pageNumber;
    public Integer pageSize;
    public Integer totalPages;
    public Integer totalCount;  

    List<SheetDetails> data;

    class SheetDetails {
        public String id;
        public String name;
        public String accessLevel;
        public String permalink;
        public Datetime createdAt;
        public Datetime modifiedAt;
    }
}
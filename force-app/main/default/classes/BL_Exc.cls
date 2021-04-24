public with sharing class BL_Exc {
    public String name;
    public String message;
    public Integer code;
    public BL_Exc(){}
    public BL_Exc(String name, String message, Integer code) {
        this.name = name;
        this.message = message;
        this.code = code;
    }
}
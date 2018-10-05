public class BL_ChartJS {

    public class DataSet {

        @AuraEnabled
        public String label;
        @AuraEnabled
        public List<Object> data = new List<Object>();
        @AuraEnabled
        public Decimal lineTension;
        @AuraEnabled
        public Boolean fill;
        @AuraEnabled
        public String borderColor;
        @AuraEnabled
        public String backgroundColor;
        @AuraEnabled
        public String pointHoverBorderColor;
        @AuraEnabled
        public String pointHoverBackgroundColor;

        public DataSet() {
            lineTension = 0.25;
            fill = false;
        }

        public void setPrimaryColor(String color) {
            borderColor = color;
            pointHoverBorderColor = color;
        }

        public void setSecondaryColor(String color) {
            backgroundColor = color;
            pointHoverBackgroundColor = color;
        }

        public void setSecondaryColorBasedOnPrimaryColor() {
            String color = borderColor.removeEnd('FF') + '11';
            backgroundColor = color;
            pointHoverBackgroundColor = color;
        }

        public void fill() {
            fill = true;
        }

        public void addPoint(BL_ChartJS.Point point) {
            data.add(point);
        }
    }

    public class Point {

        @AuraEnabled
        public Object x;
        @AuraEnabled
        public Object y;
        @AuraEnabled
        public Integer matchPoints;
        @AuraEnabled
        public String matchDate;
        @AuraEnabled
        public String enemyName;
        @AuraEnabled
        public String enemyColor;

        public Point(Object x, Object y) {
            this.x = x;
            this.y = y;
        }
    }
}
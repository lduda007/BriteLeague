public class BL_ColorHelper {

    public static final String BLUE = '#2196F3FF';
    public static final String TEAL = '#00BCD4FF';
    public static final String INDIGO = '#3F51B5FF';

    private static final List<String> hexColors = new List<String>{
            '#FF8C13FF', '#C715FFFF', '#20B2AAFF', '#DC143CFF', '#6495EDFF', '#A55043FF', '#778899FF', '#FF1493FF',
            '#F4A460FF', '#EE82EEFF', '#FFD720FF', '#8B4513FF', '#4949A0FF', '#148B8BFF', '#14FF7FFF', '#556B2FFF',
            '#0FD9FAFF', '#10DC29FF', '#534081FF', '#0495CDFF', '#EF6CE8FF', '#BD34DAFF', '#247C1BFF', '#0C8E5DFF',
            '#635B03FF', '#CB7ED3FF', '#65ADEBFF', '#5C1ACCFF', '#F2F853FF', '#11F891FF', '#7B39AAFF', '#53EB10FF',
            '#54137DFF', '#275222FF', '#F09F5BFF', '#3D0A4FFF', '#22F767FF', '#D63034FF', '#9A6980FF', '#DFB935FF',
            '#3793FAFF', '#90239DFF', '#E9AB2FFF', '#AF2FF3FF', '#057F94FF', '#B98519FF', '#388EEAFF', '#028151FF',
            '#F0E68CFF', '#0DE018FF', '#93AB1CFF', '#95BAF0FF', '#369976FF', '#18F71FFF', '#4B8987FF', '#491B9EFF',
            '#829DC7FF', '#BCE635FF', '#CEA6DFFF', '#20D4ADFF', '#2D74FDFF', '#3C1C0DFF', '#12D6D4FF', '#48C000FF',
            '#2A51E2FF', '#E3AC12FF', '#FC42A8FF', '#2FC827FF', '#1A30BFFF', '#B740C2FF', '#42ACF5FF', '#2FD9DEFF',
            '#FAFB71FF', '#05D1CDFF', '#C471BDFF', '#94436EFF', '#C1F7ECFF', '#CE79EEFF', '#BD1EF2FF', '#93B7E4FF',
            '#3214AAFF', '#184D3BFF', '#AE4B99FF', '#7E49D7FF', '#4C436EFF', '#FA24CCFF', '#CE76BEFF', '#A04E0AFF',
            '#9F945CFF', '#DCDE3DFF', '#10C9C5FF', '#70524DFF', '#0BE472FF', '#8A2CD7FF', '#6152C2FF', '#CF72A9FF',
            '#E59338FF', '#EEDC2DFF', '#D8C762FF', '#D8C762FF'
    };

    public static List<String> getHexColors(Integer size) {
        List<String> l = new List<String>();
        for(Integer i = 0; i < size; i++) {
            l.add(hexColors[Math.mod(i, hexColors.size())]);
        }
        return l;
    }

    public static String getHexColorOnIndex(Integer index) {
        return hexColors.get(Math.mod(index, hexColors.size()));
    }
}
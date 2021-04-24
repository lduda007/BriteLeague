/**
 * Created by Adam on 5/24/2018.
 */

public class BTN_BSS_SendToBSNewUser_Mock implements HttpCalloutMock {

	public static final Integer STATUS_CODE_SUCCESS = 200;
	public static final Integer STATUS_CODE_BAD_REQUEST = 400;

	private Integer statusCode;

	public BTN_BSS_SendToBSNewUser_Mock(Integer statusCode){
		this.statusCode = statusCode;
	}

	public HTTPResponse respond(HTTPRequest req) {
		HttpResponse res = new HttpResponse();

		res.setHeader('Content-Type', 'application/json');
		res.setStatusCode(statusCode);

		if(statusCode == STATUS_CODE_SUCCESS)
			res.setBody(bsNewUserSuccessResponse());
		else
				res.setBody(bsNewUserFailureResponse());

		return res;
	}

	private String bsNewUserSuccessResponse(){
		BTN_BSS_DTO.ResponseStatus responseStatus = new BTN_BSS_DTO.ResponseStatus('Success', null, 123);
		return JSON.serialize(responseStatus);
	}

	private String bsNewUserFailureResponse(){
		BTN_BSS_DTO.ResponseStatus responseStatus = new BTN_BSS_DTO.ResponseStatus('Failure', 'Error', null);
		return JSON.serialize(responseStatus);
	}
}
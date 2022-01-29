package dmcblue.gambit.server;

import interealmGames.server.http.ErrorObject;
import dmcblue.gambit.server.parameters.AiMoveParams;
import dmcblue.gambit.server.parameters.MoveParams;
import interealmGames.common.uuid.UuidV4;
import dmcblue.gambit.ai.Level;
import dmcblue.gambit.server.ExternalGameRecordObject;
import dmcblue.gambit.server.ExternalGameRecordObject;
import dmcblue.gambit.server.parameters.CreateParams;
import interealmGames.browser.api.Error;
import interealmGames.browser.api.ApiInterface;
import interealmGames.browser.api.ApiInterface.GetRequest;
import interealmGames.browser.api.ApiInterface.PostRequest;
import interealmGames.browser.api.ApiInterface.Response;
import interealmGames.common.serializer.object.Json;
import interealmGames.common.Http;
import haxe.Json as Json;

class Api {
	private var api:ApiInterface;
	private var url:String;
	public function new(api:ApiInterface, url:String) {
		this.api = api;
		this.url = url;
	}

	public function checkStatus(callback:Bool -> Void):Void {
		var request:GetRequest = {
			url: this.url + '/status',
			onResponse: function(response:Response) {
				if (response.status < 400) {
					callback(true);
				} else {
					callback(false);
				}
			},
			onReject: function(error:Response) {
				callback(false);
			}
		};
		this.api.get(request);
	}

	private function handleGameResponse(callback:ExternalGameRecordObject -> ErrorObject -> Void) {
		return function(response:Response) {
			if (response.status < 400) {
				var game:ExternalGameRecordObject = cast Json.parse(response.data);
				callback(game, null);
			} else {
				var error:ErrorObject = cast Json.parse(response.data);
				callback(null, error);
			}
		};
	}

	public function aiJoin(id:UuidV4, callback:ExternalGameRecordObject -> ErrorObject -> Void):Void {
		var request:GetRequest = {
			url: this.url + '/game/${id}/ai/join',
			onResponse: this.handleGameResponse(callback)
		};
		this.api.get(request);
	}

	public function aiMove(gameId:UuidV4, params:AiMoveParams, callback:ExternalGameRecordObject -> ErrorObject -> Void):Void {
		var request:PostRequest = {
			url: this.url + '/game/${gameId}/ai/move/',
			data: Json.stringify(params),
			onResponse: this.handleGameResponse(callback)
		};
		this.api.post(request);
	}

	public function create(params:CreateParams, callback:ExternalGameRecordObject -> ErrorObject -> Void):Void {
		var request:PostRequest = {
			url: this.url + '/create',
			data: Json.stringify(params),
			onResponse: this.handleGameResponse(callback)
		};
		this.api.post(request);
	}

	public function get(id:UuidV4, callback:ExternalGameRecordObject -> ErrorObject -> Void):Void {
		var request:GetRequest = {
			url: this.url + '/game/${id}',
			onResponse: this.handleGameResponse(callback)
		};
		this.api.get(request);
	}

	public function join(id:UuidV4, callback:ExternalGameRecordObject -> ErrorObject -> Void):Void {
		var request:GetRequest = {
			url: this.url + '/game/${id}/join',
			onResponse: this.handleGameResponse(callback)
		};
		this.api.get(request);
	}

	public function move(gameId:UuidV4, params:MoveParams, callback:ExternalGameRecordObject -> ErrorObject -> Void):Void {
		var request:PostRequest = {
			url: this.url + '/game/${gameId}/move',
			data: Json.stringify(params),
			onResponse: this.handleGameResponse(callback)
		};
		this.api.post(request);
	}

	public function pass(gameId:UuidV4, playerId:UuidV4, callback:ExternalGameRecordObject -> ErrorObject -> Void):Void {
		var request:GetRequest = {
			url: this.url + '/game/${gameId}/pass/${playerId}',
			onResponse: this.handleGameResponse(callback)
		};
		this.api.get(request);
	}
}

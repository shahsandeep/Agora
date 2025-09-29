class AgoraCallParamsModel{
  String? callerId;
  String? receiverId;
  String? receiverName;
  String? channelName;
  String? tempToken;
  String? callerName;

  AgoraCallParamsModel({
    this.callerId,
    this.receiverId,
    this.channelName,
    this.tempToken,
    this.callerName, 
    this.receiverName
  });
}
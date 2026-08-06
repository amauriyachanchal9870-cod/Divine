class SupportTicketModel {
  bool? status;
  List<SupportTicket>? data;

  SupportTicketModel({this.status, this.data});

  SupportTicketModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = <SupportTicket>[];
      json['data'].forEach((v) {
        data!.add(SupportTicket.fromJson(v));
      });
    }
  }
}

class SupportTicket {
  String? id;
  String? ticketId;
  String? user;
  String? userName;
  String? userPhone;
  String? subject;
  String? message;
  String? status;
  String? reply;
  String? createdAt;
  String? updatedAt;

  SupportTicket({
    this.id,
    this.ticketId,
    this.user,
    this.userName,
    this.userPhone,
    this.subject,
    this.message,
    this.status,
    this.reply,
    this.createdAt,
    this.updatedAt,
  });

  SupportTicket.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    ticketId = json['ticketId'];
    user = json['user'];
    userName = json['userName'];
    userPhone = json['userPhone'];
    subject = json['subject'];
    message = json['message'];
    status = json['status'];
    reply = json['reply'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }
}

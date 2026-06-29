
class ExecAction {final List<String>? command; ExecAction({this.command}); factory ExecAction.fromJson(Map<String, dynamic> json) {return ExecAction(command: json['command'] != null ? List<String>.from(json['command']) : null);} Map<String, dynamic> toJson() {return {if (command != null) 'command' : command};}}

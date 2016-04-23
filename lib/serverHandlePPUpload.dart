import 'dart:io';
import 'dart:convert';
import 'package:skydev/database.dart';

void handlePPUpload(HttpRequest req){
  _readBody(req, (body) {

        // handle your dataURL
        // example with image : data:image/jpeg;base64,/9j/4S2YRXhpZgAATU0AK...

        // return result
        HttpResponse res = req.response;
        res.statusCode = HttpStatus.CREATED;
        res.contentLength = 0;
        res.close();
      });
}

/// Read body of [request] and call [handleBody] when complete.
_readBody(HttpRequest request, void handleBody(String body)) {
  String bodyString = ""; // request body byte data
  final completer = new Completer();
  final sis = new StringInputStream(request.inputStream, Encoding.UTF_8);
  sis.onData = (){
    bodyString = bodyString.concat(sis.read());
  };
  sis.onClosed = () {
    completer.complete("");
  };
  sis.onError = (Exception e) {
    print('exception occured : ${e.toString()}');
  };
  // process the request and send a response
  completer.future.then((_){
    handleBody(bodyString);
  });
}

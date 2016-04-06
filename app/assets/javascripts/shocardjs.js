function pollSession(id, mode) {

    var TIMEOUT = 1000;
    var session_id = id;
    var mode = mode;

    setTimeout(poll, TIMEOUT);

    function poll() {
        console.log("Polling... QR: " + session_id);
        $.get('/sessions/' + session_id, null, poll_success)
            .error(poll_failed);
    }

    function poll_success(data){
        if (data.state != "initial")
        {
            if (mode == "registrations") {
                $("#user_shocardid").val(data.state);
                $("input.btn").css({'background-color' : '#008000'});
                $("#user_current_password").css({'background-color' : '#F08080'});
                $("#user_current_password").focus();
                $("#user_shocardid").css({'background-color' : '#DCDCDC'});
                $("input.btn").prop('value', 'Confirm');
            }
            else {
                window.location.replace("/" + mode + "/ok");
            }
        }
        else
        {
            setTimeout(poll, TIMEOUT);
        }
    }

    function poll_failed(){
        console.log("Polling failed, QR: " + session_id);
    }

}

function buttonClick(session_id) {
    username = $("#user_email").val();
    console.log("Notifying " + username + " phone");

    data = {"username": username, "session_id": session_id}
    $.post('/logins/new/', data, null)
}

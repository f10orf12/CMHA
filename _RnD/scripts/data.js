
var requestData = function (u, O, callback) {
    errors = [
    { "errornum": "4", "errortext": "The connection timed out. Please try again when you have a better network connection." },
    { "errornum": "5", "errortext": "The request was denied. Please contact the network administrator." },
    { "errornum": "6", "errortext": "An Internal Server Error caused the application to fail. Please contact the network administrator." }
    ]
    function foo() {
        $.ajax({
            method: "POST",
            url: u,
            data: JSON.stringify(O),
            timeout: 10000
        })
        .done(function (data) {
            callback(JSON.parse(data));
        })
        .fail(function (xhr, textStatus, error) {
            if (xhr.readyState == 0 && xhr.statusText == 'timeout') {
                error = errors[0];
            }
            if (xhr.readyState == 0 && xhr.statusText == 'error') {
                error = errors[1];
            }
            if (xhr.readyState == 4) {
                error = errors[2]
            }
            callback(error)
        });
    }


    return {
        post: function (u, O, callback) {
            foo(u, O, callback);
        }
    }
} ();
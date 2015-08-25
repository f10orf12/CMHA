var i;
var pbmApp = (function () {

    function changeQuestion(i) {
        if (i == Questions.length) {
            $('#pbm3').hide();
            PBMForm.setPBMForm();
            submitResponses();
            return;
        }
        $("#pbm3").effect('drop', '', 200, callback);

        function callback() {// callback function to bring a hidden box back
            $('#ddChoice').val(5);
            $('#comment').val('');
            $('#pbm-qnum').html(Questions[i].qnum);
            if (mode === 1) {
                $('#ddChoice').val(Questions[i].answer);
                $('#comment').val(Questions[i].comment);
                $('#pbm3 > div > p').html(Questions[i].desc);
            }
            else {
                $('#pbm3 > div > p').html(Questions[i].qtext);
            }
            setTimeout(function () {
                $("#pbm3").removeAttr("style").hide().fadeIn(200); 
            }, 750);
        };
    }

    function submitResponses() {
        var uri = 'pbmResponses.ashx';
        $('.loader').show();
        if (mode === 1 && change === 0) {
            $('.loader').hide();
            $('#pbm4').fadeIn();
            $('#pbm-confirm').html(Person.confirmation);
            return;
        }
        else {
            requestJSON(fp + 'pbmForm.ashx', PBMForm, function (data) {
                if (data.hasOwnProperty('errornum')) {  //check to see if there was an error uploading the basic data
                    var etxt = data.errortext;
                    return errorState(etxt);
                }
                else {
                    Confirmation.setNumber(data.number);
                    Confirmation.setFormID(data.formID);
                    var rlen = responses.length;
                    for (var i = 0; i < rlen; i++) {
                        responses[i].formID = Confirmation.getFormID();
                    }
                    if (mode === 1 && change === 1) {//if the user changes something during review
                        uri = 'pbmResponsesUpdate.ashx';
                    }
                    requestJSON(fp + uri, responses, function (data) {
                        if (data.hasOwnProperty('errornum')) {  //check to see if there was an error uploading the basic data
                            var etxt = data.errortext;
                            errorState(etxt);
                        }
                        else {
                            $('.loader').hide();
                            $('#pbm4').fadeIn();
                            $('#pbm-confirm').html(Confirmation.number);
                        }
                    });
                }
            });
        }
    }
    /*Public pbmApp methods*/
    return {
        qnum: 0,
        currentPage: '',

        nextQuestion: function () {
            i++;
            var a = $('#ddChoice').val();
            var c = $('#comment').val();
            pbmResponse(i, a, c);
            changeQuestion(i)
        },
        prevQuestion: function () {
            i--;
            changeQuestion(i);
        },

        reviewResponses: function () {
            $('#btn-pbm-edit').show();
            $('#pbm-qnum').html(Questions[i].qnum);
            $('#ddChoice').val(Questions[i].answer);
            $('#comment').val(Questions[i].comment);
            $('#pbm3 > div > p').html(Questions[i].desc);
        },
        editResponse: function () {

        }
    }
})();

var PBMForm = {
    setPBMForm: function () {
        for (var property in Person) {
            if (Person.hasOwnProperty(property)) {
                if (Person[property] == null) { delete Person[property] }
            }
        }
        $.extend(PBMForm, Person);
        return PBMForm;
    }
}

$(document).ready(function () {
    i = 0;

    $('#pbm-month').on('change', function () {
        $('#pbm-day').focus();
    });

    $('#pbm-login').on('click', function () {
        $('.loader').show();
        var dob = $('#pbm-month').val() + '/' + $('#pbm-day').val() + '/' + $('#pbm-year').val();
        var ssn4 = $('#pbm-ssn4').val();
        var uri = 'pbmQuestions.ashx';
        LoginInfo.dob = dob;
        LoginInfo.ssn4 = ssn4;
        requestJSON(fp + 'pbmLogin.ashx', LoginInfo, function (data) {
            if (data.hasOwnProperty('errornum')) {  //error handling 
                errorState(data.errortext);
            }
            else {
                $.extend(Person, data);
                Person.setYear();
                if (Person.confirmation != null) {
                    uri = 'pbmReview.ashx';
                    Person.getUserID(); //adds the userID to the updatedby property in Person
                    LoginInfo.getNumber(); //gets confirmation for use in LoginInfo
                }
                requestJSON(fp + uri, LoginInfo, function (data) {
                    Questions = data;
                    if (Questions.hasOwnProperty('errornum')) {
                        var etxt = Questions.errortext;
                        errorState(etxt);
                        return;
                    }
                    else {
                        $('#pbmName').val(Person.fname + ' ' + Person.lname)
                        $('#pbmEmployeeID').val(Person.employeeID)
                        $('#pbmSupervisor').val(Person.supervisor)
                        $('#pbmEmail').val(Person.email)
                        $('#pbm-qnum').html(Questions[i].qnum);
                        $('#pbm3 > div > p').html(Questions[i].qtext);
                        $('#content1').hide();
                        $('#fname').val(Person.fname);
                        $('#lname').val(Person.lname);
                        $('#address').val(Person.address);
                        $('#suite').val(Person.suite);
                        $('#city').val(Person.city);
                        $('#state').val(Person.state);
                        $('#zip').val(Person.zip);
                        $('#phone').val(Person.phone);
                        $('#dept').val(Person.dept);
                        $('#email').val(Person.email);
                        $('#pbm1').hide();
                        $('#pbm2').fadeIn();
                        $('.loader').hide();
                    }
                });
            }
        });
    });

    $('#btn-pbm-next').on('click', function (e) {
        e.preventDefault();
        pbmApp.nextQuestion();
    });

    $('#btn-pbm-cont').on('click', function (e) {
        e.preventDefault();
        $('#pbm2').hide();
        $('#pbm3').fadeIn();
        if (Person.confirmation != null) {
            $('#modal').show()
            $('#ddChoice').attr('disabled', true);
            $('#comment').attr('readonly', true);
        }
    });

    $('#btn-pbm-edit').on('click', function (e) {
        e.preventDefault();
        change = 1;
        $('#ddChoice').val(5);
        $('#comment').val('');
        $('#btn-pbm-next').hide();
        $('#btn-pbm-edit').hide();
        $('#btn-pbm-save').show();
        $('#ddChoice').attr('disabled', false);
        $('#comment').attr('readonly', false);
    });

    $('#btn-pbm-save').on('click', function (e) {
        e.preventDefault();
        pbmApp.nextQuestion();
        $('#btn-pbm-next').show();
        $('#btn-pbm-edit').show();
        $('#btn-pbm-save').hide();
        $('#ddChoice').attr('disabled', true);
        $('#comment').attr('readonly', true);
    });

    $('#btn-pbm-exit').on('click', function (e) {
        e.preventDefault();
        cmha.reset();
    });
});
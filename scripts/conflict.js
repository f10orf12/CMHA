'use strict';

var q = 1;

var conflictApp = function () {
    var change = 0, /*0 = no changes to coiForm/coiConflict, 1 = change*/
    desc = '',
    qlen = cmha.questions.length,
    mode = '0'; //0 = normal, 1 = review

    function endQuestions() {
        if (q === qlen) {
            Form.setcompletedBy();
            Form.setSignature();
            CoIForm.setCoIForm();
            var conflicts = calcConflicts();
            CoIForm.numConflicts = conflicts;
            var results = '';
            if (conflicts === 0) {
                results = "Based on your self-disclosure, you answered 'NO' to each question on the Conflict of Interest disclosure questionnaire.  To confirm and submit your answers click the 'Finish' button. Otherwise, click 'Edit' to change your answers.";
            }
            else if (conflicts === 1) {
                results = "Based on your self-disclosure, you answered 'YES' to " + conflicts + " question on the Conflict of Interest disclosure questionnaire.  To confirm and submit your answers click the 'Finish' button. Otherwise, click 'Edit' to change your answers.";
            }
            else {
                results = "Based on your self-disclosure, you answered 'YES' to " + conflicts + " questions on the Conflict of Interest disclosure questionnaire.  To confirm and submit your answers click the 'Finish' button. Otherwise, click 'Edit' to change your answers.";
            }
            $('#results').html(results);
            $('#question').hide();
            $('#review').hide();
            $('#content4').fadeIn();
            return true;
        }
    }

    function calcConflicts() {
        var conflicts = 0;
        var rlen = responses.length;
        for (i = 0; i < rlen; i += 1) {
            if (responses[i].answer === true || responses[i].answer === "True") {
                conflicts++;
            }
        }
        return conflicts;
    }


    return {

        uri: 'coiConflictUpdate.ashx',
        questionAdvance: function () {
            q++;
            if (!endQuestions()) {
                $("#question").effect('drop', '', 200, callback);
                function callback() {// callback function to bring a hidden box back
                    $('#qnum').html(q);
                    $('#question > div > p').html(cmha.questions[q]);
                    endQuestions();
                    setTimeout(function () {
                        $("#question").removeAttr("style").hide().fadeIn(200);
                    }, 750);
                }
            }
        },

        coiReview: function () {
            $('#rqnum').html(q);
            $('#review > div >p').html(cmha.questions[q]);
            if (responses[q - 1].answer === true || responses[q - 1].answer === "True") {
                $('#answer').html('YES');
                $('#rdescription').html(responses[q - 1].desc);
            }
            else {
                $('#answer').html('NO');
                $('#rdescription').html('');
            }
        },

        reviewAnswer: function () {
            if (!endQuestions()) {
                $('#review > .controls').hide();
                $("#review").effect('drop', '', 200, callback);
                // callback function to bring a hidden box back
                function callback() {
                    conflictApp.coiReview();
                    setTimeout(function () {
                        $("#review").removeAttr("style").hide().fadeIn(200);
                        $('#review > .controls').fadeIn('fast');
                    }, 750);
                }
            }
        }
    };

} ();

$(document).ready(function () {
    // variables used in the following switch-navigation
    var dob = '', ssn4 = '', wA = '', wP = '', wD = '', desc = '',
    etxt = "Please enter all required information.";

    //main navigation
    $("input").on('click', function (e) {
        var action = $(e.target).attr('id');

        switch (action) {
            case 'login':
                $('.loader').show();
                if ($('#coi-dob').val() === '' || $('#coi-ssn4').val().length < 4) { /*basic form validation and error messaging to end user*/
                    errorState(etxt);
                    break;
                }
                else {
                    dob = $('#coi-month').val() + '/' + $('#coi-day').val() + '/' + $('#coi-year').val();
                    ssn4 = $('#coi-ssn4').val();
                    LoginInfo.dob = dob;
                    LoginInfo.ssn4 = ssn4;
                    requestJSON(fp + 'coiLogin.ashx', LoginInfo, function (data) { //validates the username and password
                        if (data.hasOwnProperty('errornum')) {//error handling
                            errorState(data.errortext);
                        }
                        else {//successful login
                            $.extend(Person, data);
                            $('.loader').hide();
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
                            $('#content2').fadeIn();
                            if (Person.formID != '') {//if a form ID is returned with the Person, they have already completed a form
                                LoginInfo.formID = Person.formID;
                                requestJSON(fp + 'coiReview.ashx', LoginInfo, function (data) { //loads a pre-existing form
                                    responses = data;
                                });
                                requestJSON(fp + 'coiConfirmation.ashx', LoginInfo, function (data) { //gets an existing confirmation number
                                    $.extend(Confirmation, data);
                                    Confirmation.setFormID(Person.getFormID());
                                    $('#confirmation').html(LoginInfo.number);
                                });
                            }
                            else {
                                requestJSON(fp + 'ddsupplier.ashx', '', function (data) { //returns list of departments for use in drop downs
                                    Departments = data.Departments;
                                    var dlen = Departments.length;
                                    var ddlist = '';
                                    for (i = 0; i < dlen; i += 1) {
                                        ddlist += '<option value=' + i + '>' + Departments[i].deptName + '</option>'
                                    }
                                    $('#wDept').append(ddlist);
                                    $('.loader').hide();
                                });
                            }
                        }
                    });
                    break;
                }

            case 'continue':
                $('.loader').show();
            case 'update':
                Form.addrVerified = true;
                Person.address = $('#address').val();
                Person.city = $('#city').val();
                Person.state = $('#state').val();
                Person.zip = $('#zip').val();
                Person.workPhone = $('#phone').val();
                Person.lname = $('#lname').val();
                Person.fname = $('#fname').val();
                Person.dept = $('#dept').val();
                Person.email = $('#email').val();
                Person.suite = $('#suite').val();
                if (Person.formID !== '') {
                    $('.loader').hide();
                    $('#modal').show();
                    break;
                }
                else {
                    $('#content2').hide();
                    $('#content3').fadeIn();
                    $('#wDept').focus();
                    $('.loader').hide();
                    break;
                }

            case 'btn-wAddr': /*validates and updates user work address information*/
                etxt = "Fields outlined in red are required.";
                if ($('#wAddr').val() === '') {
                    $('#wAddr').addClass('red_border');
                    errorState(etxt);
                }
                if ($('#wCity').val() === '') {
                    $('#wCity').addClass('red_border');
                    errorState(etxt);
                }
                if ($('#wState').val() === '') {
                    $('#wState').addClass('red_border');
                    errorState(etxt);
                }
                if ($('#wZip').val() === '') {
                    $('#wZip').addClass('red_border');
                    errorState(etxt);
                }
                if ($('#wTel').val() === '') {
                    $('#wTel').addClass('red_border');
                    errorState(etxt);
                }
                if ($('#wDept').val() === '') {
                    $('#wDept').addClass('red_border');
                    errorState(etxt);
                }
                if ($('#wDept').val() === '' || $('#wTel').val() === '' || $('#wZip').val() === '' || $('#wState').val() === '' || $('#wCity').val() === '' || $('#wAddr').val() === '') {
                    break;
                }
                else {
                    wA = $('#wAddr').val() + ', ' + $('#wCity').val() + ', ' + $('#wState').val() + ' ' + $('#wZip').val();
                    wP = $('#wTel').val();
                    wD = $('#wDept').val();
                    WorkInfo.setWorkInfo(wA, wP, wD); /*Enter work address info in object*/
                    $('#content2').hide();
                    $('#content3').hide();
                    $('#question').fadeIn();
                    break;
                }

            case 'edit1': /*review answers at end of questionnaire*/
                if (responses.length === 0) {
                    $('#content2').hide();
                    $('#content3').hide();
                    $('#question').fadeIn();
                    break;
                }
                else {
                    $('#modal').show();
                    break;
                }

            case 'edit0': /*edit personal information*/
                $('#continue').hide();
                $('#edit0').hide();
                $('#update').show();
                $('input').attr('readonly', false);
                $('#content2 > .page-details > .col-2 > div > .no_border').removeClass('no_border');
                break;

            case 'yes': /*user answer*/
                $('#conflict').fadeIn();
                $('#yes').hide();
                $('#no').hide();
                $('#save').fadeIn();
                $('#description').focus();
                break;

            case 'save':  /*saves user conflict description*/
                desc = $('#description').val()
                if (desc == '') {
                    $('#description').addClass('red_border');
                    $('#description').attr('placeholder', 'Please enter an explanation...');
                    return;
                }
                else {
                    $('#yes').fadeIn();
                    $('#no').fadeIn();
                    $('#conflict').hide();
                    $('#description').val('');
                    $('#save').hide();
                    $('#description').removeClass('red_border');
                    $('#description').attr('placeholder', 'Please explain...');
                    if (mode === 0) {
                        answer(q, true, desc);
                        conflictApp.questionAdvance();
                        break;
                    }
                    else {
                        responses[q - 1].answer = true;
                        responses[q - 1].desc = desc;
                        $('#question').hide();
                        $('#review').fadeIn();
                        conflictApp.reviewAnswer();
                        break;
                    }
                }

            case 'no': /*user answer*/
                if (mode === 0) {
                    $('#question').hide();
                    answer(q, false, '');
                    conflictApp.questionAdvance();
                    break;
                }
                else {
                    responses[q - 1].answer = false;
                    responses[q - 1].desc = '';
                    $('#question').hide();
                    $('#review').fadeIn();
                    conflictApp.reviewAnswer();
                    break;
                }

            case 'next': /*user can navigate to the next answer during reivew process*/
                q++;
                conflictApp.reviewAnswer();
                break;

            case 'btn-review':  /*enters review mode and allows the user to edit responses*/
                $('#modal').fadeOut(100);
                mode = 1; /* 1 = reivew, 0 = normal*/
                if (app == 'coi') {
                    $('#content2').hide();
                    $('#content3').hide();
                    $('#content4').hide();
                    q = 1;
                    conflictApp.coiReview();
                    //coiReview();
                    $('#review').fadeIn();
                }
                if (app == 'pbm') {
                    pbmApp.reviewResponses();
                }

                break;

            case 'btn-cancel':  /*this exits the review mode*/
                if (q === 17) {
                    $('#content4').fadeIn();
                    $('#modal').hide();
                }
                else {
                    cmha.reset();
                }
                break;

            case 'btn-ok': /*exits an error modal and returns user to login screen */
                $('#modal-error').hide();
                $('#coi-dob').val('');
                $('#coi-ssn4').val('');
                $('#pbm-dob').val('');
                $('#pbm-ssn4').val('');
                $('.loader').hide();
                break;

            case 'edit2': /*edit an individual answer*/
                $('#review').hide();
                change = 1;
                q--;
                conflictApp.questionAdvance();
                break;

            case 'finish':
                $('#modal-verify').show();
                break;

            case 'verify': /*upload answers to database*/
                $('#modal-verify').hide();
                $('.loader').show();
                $('#content4').hide();
                $('#content5').fadeIn();
                if (Person.formID != '' && change === 1) {
                    conflictApp.uri = 'coiConflictUpdate.ashx';
                }
                else {
                    conflictApp.uri = 'coiConflict.ashx';
                }

                if (Person.formID !== '' && change === 0) {//existing form and no changes, show existing confirmation number  ?????
                    $('.loader').hide();
                    $('#confirmation').html(Confirmation.number);
                    break;
                }
                /*Begin submitResponses - 4 step process: 
                1.CoIForm --> returns confirmation number 2. update responses 3. upload responses 4. display success or error */
                $('.loader').show();
                requestJSON(fp + 'coiForm.ashx', CoIForm, function (data) {//upload CoIForm object and get confirmation number
                    if (data.hasOwnProperty('errornum')) {  //check to see if there was an error uploading the basic data
                        errorState(data.errortext);
                    }
                    else {//success CoIForm upload
                        Confirmation.setNumber(data.number);
                        Confirmation.setFormID(data.formID);
                        var rlen = responses.length;
                        for (i = 0; i < rlen; i += 1) {//update necessary values to individual responses
                            responses[i].formID = Confirmation.getFormID();
                            responses[i].userID = Person.getUserID();
                        }
                        requestJSON(fp + conflictApp.uri, responses, function (data) {//upload CoI responses
                            if (data.hasOwnProperty('errornum')) {  //check to see if there was an error uploading the basic data
                                errorState(data.errortext);
                            }
                            else {//successful upload
                                $('.loader').hide();
                                $('#confirmation').html(Confirmation.number);
                            }
                        });
                    }
                });
                break;
            /*End submitResponses*/ 


            case 'exit':  /*exit the application and reset to default state*/
                cmha.reset();
                $('#coi').hide();
                $('#pbm').hide();
                $('#landing').fadeIn(100);
                break;

            default:  /*there are a few inputs/form fields that get collected here when no action is necessary.*/
                break;
        }
    });

    $('#coi-month').on('change', function () {
        $('#coi-day').focus();
    });

    $('#wDept').on('change', function () {//populate work address from dropdown
        var i = $('#wDept').val()
        $('#wAddr').val(Departments[i].addr1 != undefined ? Departments[i].addr1 : '');
        $('#wCity').val(Departments[i].city != undefined ? Departments[i].city : '');
        $('#wState').val('OH');
        $('#wZip').val(Departments[i].zip != undefined ? Departments[i].zip : '');
        $('#wTel').val(Departments[i].phone != undefined ? Departments[i].phone : '');
    });

});




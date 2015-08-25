var fp = ''; //test environment file path.  Can be removed for production

// Wait for device API libraries to load
document.addEventListener("deviceready", onDeviceReady, false);

// device APIs are available
function onDeviceReady() {
    // Register the event listener
    document.addEventListener("backbutton", onBackKeyDown, false);
    fp = "http://www.cmha.net:83/coi/"; //production environment file path --> only fires if on a phone.
}

// Handle the back button
function onBackKeyDown() {
    if (window.confirm("Exit the application?")) {
        navigator.app.exitApp();
    }
}



var responses = [];

cmha = (function () {/*main function that initializes and resets the app*/

    CoIForm = {
        setCoIForm: function () {
            $.extend(CoIForm, Form, Person, LoginInfo, WorkInfo, reduceResponses());
            return JSON.stringify(CoIForm);
        }
    }
    Conflict = {
        setConflict: function () {
            $.extend(Conflict, reduceDescriptions());
            if (Person.formID) {
                Conflict.formID = Person.formID;
            }
            else {
                Conflict.formID = Confirmation.formID;
            }
            Conflict.userID = Person.employeeID;
        }
    }
    Confirmation = {
        formID: '',
        number: '',
        getFormID: function () {
            return this.formID;
        },
        setFormID: function (f) {
            this.formID = f;
        },
        setNumber: function (n) {
            this.number = n;
        }
    }
    Person = {
        getUserID: function () {
            this.userID = this.employeeID;
            return this.userID;
        },
        getFormID: function () {
            return this.formID;
        },
        setYear: function () {
            this.year = LoginInfo.getYear();
        }
    }
    Form = {
        year: '',
        completedBy: '',
        confirmationNumber: '',
        signature: '',
        updatedBy: '',
        addrVerified: false,
        setYear: function () {
            this.year = LoginInfo.year;
        },
        setcompletedBy: function (c) {
            this.completedBy = Person.userID;
        },
        setSignature: function (s) {
            this.signature = Person.fname + ' ' + Person.lname;
        }
    }
    LoginInfo = {
        number: '',
        dob: '',
        ssn4: '',
        year: '',
        getNumber: function () {
            this.number = Person.confirmation;
        },
        getYear: function () {
            return this.year;
        },
        setYear: function () {
            var d = new Date();
            this.year = d.getFullYear();
        }
    }
    WorkInfo = {
        workAddress: '',
        workPhone: '',
        workDept: '',
        setWorkInfo: function (a, p, d) {
            this.workAddress = a;
            this.workPhone = p;
            this.workDept = d;
        }
    }

    return {

        questions: [
"!--reserved--!",
"Are you employed by, been elected to, or appointed to any unit of Federal, State, or local government other than CMHA?",
"Are you employed with any organization or business entity doing business or proposing to do business with CMHA?",
"Do you supervise immediate family members or household members who currently work at CMHA?",
"Does an immediate family member or a household member supervise you in your current position at CMHA?",
"Not including your position with CMHA, do you have or are you aware of whether an immediate family member or a household member has any financial interest in any business or other organization which conducts business with CMHA?",
"Do you serve or are you aware of whether an immediate family member or a household member serves in any advisory capacity for any professional, business, government, or other organization which conducts business with CMHA?",
"Have you received or are you aware of whether an immediate family member or a household member received any tips, gifts, or favors of any intrinsic value in excess of $25.00 from any person, business, or government doing business or proposing to do business with CMHA?",
"Have you owned or sold or are you aware of whether an immediate family member or a household member owned or sold any interest in real or personal property that was rented, leased, purchased, subsidized, or otherwise used by CMHA?",
"Do you own or are you aware of whether an immediate family member or a household member owns any property for which CMHA provides housing vouchers through the Housing Choice Voucher Program?",
"Do you own or are you aware of whether an immediate family member or a  household member owns an interest in an entity that is an owner of any property for which CMHA provides housing vouchers though the Housing Choice Voucher Program?",
"Have you entered or are you aware of whether an immediate family member or a household member entered into or in any way had an economic or financial interest in any contract, subcontract, or other transaction involving CMHA?	",
"Have you or are you aware of whether an immediate family member or a household member has been involved in any transaction with CMHA where there was an exchange of property?",
"Other than wages and benefits paid to you by CMHA, have you or are you aware of whether an immediate family member or a household member received any personal financial gain from any of your activities as an employee of CMHA?",
"Other than custodians and workers classified as resident workers, have you been assigned to or performed work related to a CMHA property where you, an immediate family member, or a household member resides?",
"Are you aware of any additional information you believe may constitute an actual, apparent, or potential conflict of interest under the Conflict of Interest Policy contained in Administrative Order 11?",
"Do you anticipate that you would answer 'yes' to any of the questions above in the next 12 months?"
],

        reset: function () {
            Locations = {}
            Departments = {}
            $('#coi-month').val(1);
            $('#coi-day').val('');
            $('#coi-year').val('');
            $('#coi-ssn4').val('');
            $('#pbm-month').val(1);
            $('#pbm-day').val('');
            $('#pbm-year').val('');
            $('#pbm-ssn4').val('');
            $('#content1').fadeIn();
            $('#content2').hide();
            $('#content3').hide();
            $('#update').hide();
            $('#content4').hide();
            $('#content5').hide();
            $('#question').hide();
            $('#conflict').hide();
            $('#review').hide();
            $('.loader').hide();
            $('#coi').hide();
            $('#pbm').hide();
            $('#pbm2').hide();
            $('#pbm3').hide();
            $('#pbm4').hide();
            $('#modal').hide();
            $('#modal-error').hide();
            $('#modal-verify').hide();
            $('#userguide').hide();
            $('#wAddr').val('');
            $('#wCity').val('');
            $('#wState').val('');
            $('#wZip').val('');
            $('#wTel').val('');
            $('#btn-pbm-edit').hide();
            $('#btn-pbm-save').hide();
            $('#version').show();
            i = 0;
            q = 1;
            change = 0;
            mode = 0;
            conflicts = 0;
            app = '';
            responses = [];
            $('#qnum').html(q);
            $('#question > div > p').html(cmha.questions[q]);
            $('#landing').fadeIn();
            LoginInfo.setYear();
            Form.setYear();
            $('#version').html('Version: 0.1.68');
        }
    }

})();
/*end of reset function*/

function answer(q, a, d) {
    var response = new Response(q, a, d);
    responses.push(response);
}

function pbmResponse(q, a, c) {
    var value = q - 1;
    if (mode === 1) {
        var d = Questions[value].desc;
    }
    else {
        var d = Questions[value].qtext;
    }
    var response = new Response(q, a, d, c);
    responses.push(response)
}

function Response(qnum, answer, desc, comment, form, user) {
    this.qnum = qnum;
    this.answer = answer;
    this.desc = desc;
    this.comment = comment;
    this.formID = form;
    this.userID = user;
}

function reduceResponses() {
    var Ref = {};
    var rlen = responses.length;
    for (var i = 0; i < rlen; ++i)
        if (responses[i] !== undefined) {
            Ref['ref' + i] = responses[i].answer;
        }
    return Ref;
}

function reduceDescriptions() {//
    var Ref = {};
    Ref.formID = Confirmation.formID;
    var rlen = responses.length;
    var value = 0;
    for (var i = 0; i < rlen; ++i)
        if (responses[i] !== undefined) {
            value = i + 1;
            Ref['desc' + value] = responses[i].desc;
        }
    return Ref;
}

function errorState(t) { //display application generated error messages
    $('.loader').hide();
    $('#modal-error').show();
    $('#modal-error > .modal-content > .text > p').html(t);
}

function scrollScreen(o) {//helper function to prevent input fields from being hidden by soft keyboards
    var value = 128 - o;
    $('#' + app).addClass('screen-scroll', function () {
        $('body').animate({
            scrollTop: value
        }, 500, 'easeOutExpo');
    });
}


$(document).ready(function () {
    cmha.reset();

    $('.header').on('click', function () {
        cmha.reset();
    });

    /*Begin landing page navigation*/
    $('#coi-icon').on('click', function () {
        $('#landing').hide();
        $('#coi').fadeIn();
        app = 'coi';
        $('#appName').html('Conflict of Interest Employee Questionnaire');
        $('#version').hide();
        $('#userguide').show();
    });

    $('#pbm-icon').on('click', function () {
        $('#landing').hide();
        $('#pbm').fadeIn();
        $('#pbm1').fadeIn();
        app = 'pbm';
        $('#appName').html('Performance-based Management Feedback form');
    });
    /*End landing page navigation*/

    $('a').on('click', function (e) {  //trap clicks on urls and forces them to use the childbrowser function
        var url = $(e.target).attr('href');
        if (url == undefined) {
            //console.log($(this)); return
        }
        e.preventDefault();
        var ref = window.open(url, '_blank', 'location=no');
    });

    /*making sure input fields are not obscured by keyboards*/
    $('textarea').on('focus', function () {
        scrollScreen(0);
    });

    $('.day').on('focus', function () {
        scrollScreen(28);
    });

    //    $('#coi-ssn4').on('focus', function () {
    //        scrollScreen(0);
    //    });

    $('.input-login').on('focus', function () {
        scrollScreen(0);
    });
    //    $('.year').on('focus', function () {
    //        scrollScreen(0);
    //    });

    $('#state').on('focus', function () {
        scrollScreen(0);
    });

    $('#zip').on('focus', function () {
        scrollScreen(0);
    });

    $('#phone').on('focus', function () {
        scrollScreen(0);
    });

    $('#dept').on('focus', function () {
        scrollScreen(0);
    });

    $('#email').on('focus', function () {
        scrollScreen(0);
    });

    $('.button').on('click', function () {
        $('#' + app).removeClass('screen-scroll'), $('body').scrollTop(0);

    });

});
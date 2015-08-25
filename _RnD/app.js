var Page = {
    page: '',
    getPage: function () {
        return this.page;
    },
    setPage: function (p) {
        this.page = p
    },
    fwdPage: function (p) {
        p = 'page-' + eval(parseInt(p.slice(5)) + 1);
        this.setPage(p);
        return p;
    },
    backPage: function (p) {
        p = 'page-' + eval(parseInt(p.slice(5)) - 1);
        this.setPage();
        return p;
    }
}

var Question = {
    qnum: 1,
    qtext: [
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
    getQnum: function () {
        return this.qnum
    },
    setQnum: function (q) {
        return this.qnum = q;
    },
    plusQnum: function () {
        var q = this.qnum;
        q++;
        this.setQnum(q);
    },
    minusQnum: function () {
        return this.qnum--;
    }
}
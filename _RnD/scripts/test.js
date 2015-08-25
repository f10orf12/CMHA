var questions = [
{ steve: { fname: 'stan' }, qnum: "1", question: "Are you employed by, been elected to, or appointed to any unit of Federal, State, or local government other than CMHA?" },
{ steve: { fname: 'stan' }, qnum: "2", question: "Are you employed with any organization or business entity doing business or proposing to do business with CMHA?" },
{ steve: { fname: 'hank' }, qnum: "3", question: "Do you supervise immediate family members or household members who currently work at CMHA?" },
{ steve: { fname: 'john' }, qnum: "4", question: "Does an immediate family member or a household member supervise you in your current position at CMHA?" },
{ steve: { fname: 'randy' }, qnum: "5", question: "Not including your position with CMHA, do you have or are you aware of whether an immediate family member or a household member has any financial interest in any business or other organization which conducts business with CMHA?" },
{ steve: { fname: 'larry' }, qnum: "6", question: "Do you serve or are you aware of whether an immediate family member or a household member serves in any advisory capacity for any professional, business, government, or other organization which conducts business with CMHA?" },
{ steve: { fname: 'howdy' }, qnum: "7", question: "Have you received or are you aware of whether an immediate family member or a household member received any tips, gifts, or favors of any intrinsic value in excess of $25.00 from any person, business, or government doing business or proposing to do business with CMHA?" },
{ steve: { fname: 'frank' }, qnum: "8", question: "Have you owned or sold or are you aware of whether an immediate family member or a household member owned or sold any interest in real or personal property that was rented, leased, purchased, subsidized, or otherwise used by CMHA?" },
{ steve: { fname: 'craig' }, qnum: "9", question: "Do you own or are you aware of whether an immediate family member or a household member owns any property for which CMHA provides housing vouchers through the Housing Choice Voucher Program?" },
{ steve: { fname: 'tom' }, qnum: "10", question: "Do you own or are you aware of whether an immediate family member or a  household member owns an interest in an entity that is an owner of any property for which CMHA provides housing vouchers though the Housing Choice Voucher Program?" }
]

Object.byString = function (o, s) {
    s = s.replace(/\[(\w+)\]/g, '.$1'); // convert indexes to properties
    s = s.replace(/^\./, '');           // strip a leading dot
    var a = s.split('.');
    for (var i = 0, n = a.length; i < n; ++i) {
        var k = a[i];
        if (k in o) {
            o = o[k];
        } else {
            return;
        }
    }
    return o;
}

var repeater = (function () {
    var repeat, original, repeatParent;
    return {
        insert: function (x) {
            repeat = $(document).find('[repeat="' + x + '"]');
            repeatParent = repeat.parent();
            original = repeat.clone();
            var cloned = repeat.clone();
            var listItems = [];
            var items = cloned.find('[item]');
            for (i = 0; i < items.length; i++) {
                var item = items[i].getAttribute('item');
                listItems.push(item);
            }
            repeat.remove();

            for (z = 0; z < questions.length; z++) {
                cloned = cloned.clone();

                for (y = 0; y < listItems.length; y++) {
                    var fill = cloned.find('[item="' + listItems[y] + '"]')
                    fill[0].innerHTML = Object.byString(questions[z], listItems[y]);
                    console.log(Object.byString(questions[z], listItems[y]))
                }
                cloned.appendTo(repeatParent);
            }
        },
        refresh: function (x) {
            var repeatChildren = repeat.children();
            repeatChildren.remove();
            original.appendTo(repeat);
            repeater.insert(x);
            console.log('refreshed');
        }
    }
})();



//for (i = 0; i < repeat.length; i++) {
//    rc = repeat.children;
//    console.log('rc: ', rc[0].getAttribute('repeat'));
//    if (rc[0].getAttribute('repeat') == null) {
//        rc = rc[0].children;
//        console.log(rc[0].getAttribute('repeat'))
//    } else { i++ } 
//}
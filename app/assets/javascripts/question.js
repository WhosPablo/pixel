$(document).on("turbolinks:load", questionSetup);

function questionSetup() {
    createMentionableRecipients();
    addLabelListeners();
    createAutoLabels();
    initializeCommentSlides();
    $('.question-body').linkify();
    autosize($('#question_body'));

}

function addLabelListeners() {
   // $("#question_labels_csv")
}

function createMentionableRecipients(){
    $('.input-mentionable').ready(function() {
        $('.input-mentionable').atwho({
            at: '@',
            data: $('#mentionable-data').data('content'),
            insertTpl: '${username}, ',
            displayTpl: '<li data-id="${id}"><span>${username}</span></li>',
            limit: 15,
            searchKey: "username"
        });
    });
}

function createAutoLabels(){
    //setup before functions
    var typingTimer;                //timer identifier
    var doneTypingInterval = 3000;  //time in ms (3 seconds)

    //on keyup, start the countdown
    $('#question_body').keyup(function(){
        clearTimeout(typingTimer);
        if ($('#question_body').val()) {
            typingTimer = setTimeout(doneTyping, doneTypingInterval);
        }
    });

    //user is "finished typing," do something
    function doneTyping () {
        $.get({
            url: '/auto_labels/?question_text=' + $('#question_body').val(),
            success: function(value) {
                $("#question_labels_csv").val(Object.keys(value));
                console.log(value)
            }
        });
    }
}


function initializeCommentSlides() {
    $(".show-comments-link").on("click", function(){
        $(this).parents(".question").find(".comments-section").slideToggle(600)
    })
}

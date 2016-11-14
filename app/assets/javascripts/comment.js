$(document).on("turbolinks:load", onEnterSubmitComment);

function onEnterSubmitComment(){
    $("#comment_text").keypress(function(event) {
        if (event.which == 13) {
            event.preventDefault();
            $("#new_comment").submit();
        }
    });
};

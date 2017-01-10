// Instance the tour
var tour = new Tour({
    storage: false,
    steps: [

        {
            element: "#new-question-form",
            title: "Ask a New Question",
            content: "Ask a new question to your teammates and Quiki will automatically organize the question " +
            "and make it searchable to your organization",
            backdrop: true
        },
        {
            element: "#searchbar",
            title: "Search",
            content: "Search through your company's previously asked questions.",
            backdrop: false

        },
        {
            element: "#labels-list",
            title: "Question Labels",
            content: "As more questions are added, the most popular labels will start appear here so that you can quickly" +
            "discover information about common topics.",
            backdrop: true
        },
        {
            element: "#slack-button-pic",
            title: "Add to Slack",
            content: "Add Quiki bot to your Slack so that Quiki can start saving the questions and answers that happen" +
            " directly on Slack",
            backdrop: false
        }
    ]});



function startTour() {
    // Initialize the tour
    tour.init();


    // Start the tour
    tour.start(true);
}


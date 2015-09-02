$(function(){
  $.noty.defaults.killer = true;

  // Intercept form submit and do an ajax request
  $("#data-grabber").on('submit', function(e){
    e.preventDefault();  // prevent default form submission behaviour

    var github_url = $("#github-url").val();

    // Do some basic validation on input
    if(github_url.length < 4){
      noty({
         text: 'The Github URL you entered seems invalid!',
         layout: 'topRight',
         timeout: 4000,
         type: 'error'
      });
    }
    else{
      // Show loading indicator
      $("#loading").removeClass("hide");
      $("#result").addClass("hide");

      // Fire.....
      $.ajax({
        type: 'POST',
        url: '/get-data',
        data: { 'url' : github_url },
        dataType: 'json',
        success: function(jsonData) {
          // A status field indicated whether it was success or not
          if(jsonData['status']){
            // Simply inject data into view
            $("#total-open .panel-body").html(jsonData['open_issues']);
            $("#total-open-24h .panel-body").html(jsonData['open_issues_24h']);
            $("#total-open-7d .panel-body").html(jsonData['open_issues_7d']);
            $("#total-open-7d-24h .panel-body").html(jsonData['open_issues_7d_24h']);

            // Hide loading indicator and show result
            $("#result").removeClass("hide");
            $("#loading").addClass("hide");
          }
          else{
            noty({
               text: jsonData['error'],
               layout: 'topRight',
               timeout: 4000,
               type: 'error'
            });
          }
        },
        error: function() {
          noty({
             text: 'There was an error fetching data!',
             layout: 'topRight',
             timeout: 4000,
             type: 'error'
          });
        }
      });
    }
  });
});

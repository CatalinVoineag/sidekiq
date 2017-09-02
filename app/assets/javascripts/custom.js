show_loader_flag = true

// Progress bar for delayed_job function
function progress_job(job) {
  var job_id = job.id;
  console.log("JOB STATUS " + job.status)
  if (job_id > 0) {
    var interval;
    interval = setInterval(function(){
      show_loader_flag = false;
      console.log("getting job "+job_id);
      $.ajax({
        url: '/get_job_progress/' + job_id,
        success: function(job){
          if (job.status == "Processing") {
            var stage, progress;

            // If there are errors
            // if (job.last_error != null) {
            //   $('.progress-message').addClass('text-danger').text(job.status);
            //   $('.progress-status').addClass('text-danger');
            //   $('.progress-bar').addClass('progress-bar-danger');
            //   $('.progress').removeClass('active');
            //   $('.clear_job').show();
            //   clearInterval(interval);
            // }

            progress = job.progress_current / job.progress_max * 100;
            progress = progress.toFixed(0);
            // In job stage
            if (progress.toString() !== 'NaN' && progress.toString() !== 'Infinity'){
              $('#job_'+job_id+'_progress').text(job.progress_current + '/' + job.progress_max);
              $('#job_'+job_id+'_bar').css('width', progress + '%').text(progress + '%');
            }
          } else {
            clearInterval(interval);
            $('#job_'+job_id+'_status').text(job.status);
            $('#job_'+job.id+'_progress_bar').remove();

            if (job.status === "Failed" || job.status === "Error") {
              $('#job_'+job.id+'_redirect_link').html('<p style="color: red;">'+job.last_error+'</p>');
              css = "btn btn-danger btn-xs"
            } else {
              css = "btn btn-primary btn-xs"
            }

            // if (job.redirect_link != undefined) {
            //   $('#job_'+job.id+'_redirect_link').html('<a href="'+job.redirect_link+'" class="'+css+'">'+job.link_text+'</a>');
            // }

            // monitorBackgroundJobs(job.user_id);
          }
        },
        error: function(){
          // Job is no longer in database which means it finished successfully
          // $('.progress').removeClass('active');
          // $('#job_'+job_id+'_bar').css('width', '100%').text('100%');
          // $('#job_'+job_id+'_status').text('Successfully exported!');
          // $('.export-link').show();
          clearInterval(interval);
        }
      })
    },1000);
    // jobs_intervals.push(interval);
  }
}

// function monitorBackgroundJobs(userId) {
//   show_loader_flag = false;

//   $.ajax({
//     method: "GET",
//     url: "/get_job_notifications",
//     contentType: "application/json; charset=utf-8",
//     dataType: "json",
//     data: { user_id: userId },
//     async: true,
//     success: function(data){
//       console.log(data);
//       // prosku.createCssNotification("success", "Success fetching jobs");
//       processJobNotifications(data.jobs);
//       if(!data.keep_asking){
//         clearInterval(notification_interval);
//         notification_interval = undefined;
//       }
//     },
//     failure: function(errMsg) {
//       console.log("Problem fetching jobs "+errMsg);
//       // prosku.createCssNotification("error", "Problem fetching jobs");
//     }
//   });
// }
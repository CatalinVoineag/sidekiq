class JobTracker < ActiveRecord::Base

  ENQUEUED = "Enqueued"
  PROCESSING = "Processing"
  COMPLETE = "Complete"
  ERROR = "Error"
  FAILURE = "Failed"

end

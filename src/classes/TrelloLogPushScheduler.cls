/*************************************************************************************************
* This file is part of the Nebula Logger project, released under the MIT License.                *
* See LICENSE file or go to https://github.com/jongpie/NebulaLogger for full license details.    *
*************************************************************************************************/
public without sharing class TrelloLogPushScheduler implements System.Schedulable {

    public static List<Id> scheduleEveryXMinutes(Integer x) {
        List<Id> jobIds = new List<Id>();
        for(Integer i = 0; i < 60; i += x) {
            jobIds.add(scheduleHourly(i));
        }
        return jobIds;
    }

    public static Id scheduleHourly(Integer startingMinuteInHour) {
        String minuteString = String.valueOf(startingMinuteInHour);
        minuteString = minuteString.leftPad(2, '0');
        return scheduleHourly(startingMinuteInHour, 'Trello Log Sync: Every Hour at ' + minuteString);
    }

    public static Id scheduleHourly(Integer startingMinuteInHour, String jobName) {
        Id jobId = System.schedule(jobName, '0 ' + startingMinuteInHour + ' * * * ?', new TrelloLogPushScheduler());
        return jobId;
    }

    public void execute(SchedulableContext sc) {
        // Salesforce has a limit of 5 running batch jobs
        // If there are already 5 jobs running, then don't run this job
        // Any records that need to be processed will be processed the next time the job executes
        if(this.getNumberOfRunningBatchJobs() >= 5) return;

        Database.executebatch(new TrelloLogPusher(), 100);
    }

    private Integer getNumberOfRunningBatchJobs() {
        return [SELECT COUNT() FROM AsyncApexJob WHERE JobType='BatchApex' AND Status IN ('Processing', 'Preparing', 'Queued')];
    }

}
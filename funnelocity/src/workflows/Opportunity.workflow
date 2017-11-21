<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_close_date</fullName>
        <description>Sets the actual close date of the opportunity to the current date</description>
        <field>Actual_close_date__c</field>
        <formula>TODAY()</formula>
        <name>Set close date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Set Actual close date</fullName>
        <actions>
            <name>Set_close_date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Closed Won,Closed Lost</value>
        </criteriaItems>
        <description>This workflow rules updates the Actual close date field when the stage of an opportunity is set to Closed Won or Closed Lost</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>

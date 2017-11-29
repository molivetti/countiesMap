<cfcomponent displayname="PeterPaul" hint="Generates a script tag and JS code to initialize county names and org names" output="false">


	<cffunction name="InitializeNameLookups" hint="Build all JS var statements to permit quick lookup and allow only ints to be swapped with the server so things are as fast as possible."
				access="public"
				output="false"
				returntype="struct">

		<CFTry>

		<CFSet returnStruct = {}>

		<CFStoredproc datasource="#request.datasource#" debug="no" returnCode="no"
			procedure	= "CMS.GetParentOrgs"
			result		= "db">
			<CFProcResult name="AllParentOrgs" resultSet="1">
			<CFProcResult name="AllPlanTypes"  resultSet="2">
			<CFProcResult name="AllOrgNames"   resultSet="3">
			<CFProcResult name="AllCounties"   resultSet="4">
		</CFStoredproc>

		<CFSaveContent variable="ScriptTag">
		<cfoutput>
		<script type="text/javascript">
			var AllOLNames = new Array();</cfoutput><CFOutput query="AllOrgNames"> AllOLNames[#pk#]='#OrgName#';</CFOutput><cfoutput>
			var AllParentOrgNames = new Array();</cfoutput><CFOutput query="AllParentOrgs"> AllParentOrgNames[#pk#]='#ParentOrganization#';</CFOutput><cfoutput>
			var AllCountiesArr = new Array(); </cfoutput><CFOutput query="AllCounties">AllCountiesArr[#pk#]=['#County#','#State#'];</CFOutput><cfoutput>
		</script>
		</cfoutput>
		</CFSaveContent>

		<CFSet returnStruct = {
			ParentOrgs: AllParentOrgs,
			PlanTypes: AllPlanTypes,
			Orgs: AllOrgNames,
			Counties: AllCounties,
			script: ScriptTag
		}>


		<CFCatch type="any">

			<CFSaveContent variable="ScriptTag">
			<cfoutput>
				//ERROR during data retrieval... : #cfcatch.Type#
				// #cfcatch.Message#
				<script type="text/javascript">
					var AllOLNames = ["OLName1", "OLName2", "OLName3"];
					var AllParentOrgNames = ["ParentOrg1", "ParentOrg2", "ParentOrg3"];
					var AllCountiesArr = [];
					$.ajax(
						{
							type	:	'GET',
							url		:	'data/GetMapData.cfm', 
							async	: 	false,
							success	: 	function(data) { 
											eval(data);
											var thisCounty, thisState;
											for (var i=0;i<rawData.length;i++) {
												thisPk = rawData[i][0];
												thisCounty = rawData[i][1];
												thisState = rawData[i][2];
											
												AllCountiesArr[thisPk] = [thisCounty,thisState];
											}
										}
						}
					);
				</script>
			</cfoutput>
			</CFSaveContent>

			<cfset AllParentOrgs = queryNew("pk,ParentOrganization", "integer,varchar")>
			<cfset queryAddRow(AllParentOrgs, 3)>
			<cfset querySetCell(AllParentOrgs, "pk", 1, 1)>
			<cfset querySetCell(AllParentOrgs, "ParentOrganization", "ParentOrganization1", 1)>
			<cfset querySetCell(AllParentOrgs, "pk", 2, 2)>
			<cfset querySetCell(AllParentOrgs, "ParentOrganization", "ParentOrganization2", 2)>
			<cfset querySetCell(AllParentOrgs, "pk", 3, 3)>
			<cfset querySetCell(AllParentOrgs, "ParentOrganization", "ParentOrganization3", 3)>


			<CFSet returnStruct = {
				ParentOrgs: AllParentOrgs,
				PlanTypes: QueryNew("pk"),
				Orgs: QueryNew("pk"),
				Counties: QueryNew("pk"),
				script: ScriptTag
			}>

			<!--- <cfdump var="#cfcatch#">  --->
		</CFCatch>

		</CFTry>

		<cfreturn returnStruct />
	</cffunction>

	<cffunction name="init" access="package" output="false" returntype="(component name)">
		<cfreturn  this />
	</cffunction>
</cfcomponent>
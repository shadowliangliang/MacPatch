<cfparam name="jqGridInfoData" default="ClientGroup">

<cfset hasHWData = false>
<cffunction name="itemListFromStuctArray" access="public" returntype="any">
	<cfargument name="structArray" required="yes">
	<cfargument name="structKey" required="yes">
	<cfargument name="quoted" required="no" default="false">
	
	<cfset keyArray = ArrayNew(1)>
	<cfloop index="x" from="1" to="#arrayLen(arguments.structArray)#">
		<cfif arguments.quoted>
		<cfset _tmp =  ArrayAppend(keyArray,"'"&structArray[x][arguments.structKey]&"'")>
		<cfelse>
		<cfset _tmp =  ArrayAppend(keyArray,structArray[x][arguments.structKey])>
		</cfif>
	</cfloop>
	
	<cfreturn ArrayToList(keyArray,",")>
</cffunction>

<cffunction name="genColModelHeaderForJS" access="public" returntype="any">
	<cfargument name="colDataStruct" required="yes">
	<cfset colsArray = ArrayNew(1)>
	<cfloop index="x" from="1" to="#arrayLen(colDataStruct)#">
		<cfset _tmp =  ArrayAppend(colsArray,"'"&colDataStruct[x]['dname']&"'")>
	</cfloop>
	
	<cfsavecontent variable="jsCols">
	colNames:[<cfoutput>#ArrayToList(colsArray,",")#</cfoutput>]
	</cfsavecontent>
	<cfreturn jsCols>
</cffunction>

<cffunction name="genColModelDataForJS" access="public" returntype="any">
	<cfargument name="colDataStruct" required="yes">
	<cfset colsArray = ArrayNew(1)>
	<cfloop index="x" from="1" to="#arrayLen(colDataStruct)#">
		<cfset _tmp =  ArrayAppend(colsArray,"'"&colDataStruct[x]['dname']&"'")>
	</cfloop>
	
	<cfsavecontent variable="jsCols">
	colModel :[<cfoutput>{name:'#colDataStruct[1]['name']#',index:'#colDataStruct[1]['name']#', width:#colDataStruct[1]['width']#, align:"#colDataStruct[1]['align']#", sortable:false, resizable:false},</cfoutput>
			<cfloop index="x" from="2" to="#arrayLen(colDataStruct)#"><cfoutput>
			{name:'#colDataStruct[x]['name']#',index:'#colDataStruct[x]['name']#', width:#colDataStruct[x]['width']#, align:"#colDataStruct[x]['align']#", hidden:#colDataStruct[x]['hidden']#}<cfif x NEQ arrayLen(colDataStruct)>,</cfif></cfoutput></cfloop>
	]			
	</cfsavecontent>
	<cfreturn jsCols>
</cffunction>

<cffunction name="genColModelForTable" access="public" returntype="any">
	<cfargument name="cols" required="yes">
	<cfargument name="forFile" required="yes">
	
	<cfset var i = 2>
	<cfxml variable="MyDoc">
	<?xml version='1.0' encoding='utf-8' ?>
	<settings>
	   <columns>
	   <cfloop array="#arguments.cols#" index="item">
		<column>
			<idx><cfoutput>#i#</cfoutput></idx>
			<order><cfif #item# EQ "cuuid">1<cfset i = i - 1><cfelse><cfoutput>#i#</cfoutput></cfif></order>
			<name><cfoutput>#item#</cfoutput></name>
			<dname><cfoutput>#item#</cfoutput></dname>
			<width>100</width>
			<align>left</align>
			<hidden>false</hidden>
		</column><cfset i = i + 1>
		</cfloop>
	   </columns>
	</settings>
	</cfxml>
	<cfreturn MyDoc>
</cffunction>

<cffunction name="ConvertXmlToStruct" access="public" returntype="struct" output="false">
	<cfargument name="xmlNode" type="string" required="true" />
	<cfargument name="str" type="struct" required="true" />
	<!---Setup local variables for recurse: --->
	<cfset var i = 0 />
	<cfset var axml = arguments.xmlNode />
	<cfset var astr = arguments.str />
	<cfset var n = "" />
	<cfset var tmpContainer = "" />
	
	<cfset axml = XmlSearch(XmlParse(arguments.xmlNode),"/node()")>
	<cfset axml = axml[1] />
	<!--- For each children of context node: --->
	<cfloop from="1" to="#arrayLen(axml.XmlChildren)#" index="i">
		<!--- Read XML node name without namespace: --->
		<cfset n = replace(axml.XmlChildren[i].XmlName, axml.XmlChildren[i].XmlNsPrefix&":", "") />
		<!--- If key with that name exists within output struct ... --->
		<cfif structKeyExists(astr, n)>
			<!--- ... and is not an array... --->
			<cfif not isArray(astr[n])>
				<!--- ... get this item into temp variable, ... --->
				<cfset tmpContainer = astr[n] />
				<!--- ... setup array for this item beacuse we have multiple items with same name, ... --->
				<cfset astr[n] = arrayNew(1) />
				<!--- ... and reassing temp item as a first element of new array: --->
				<cfset astr[n][1] = tmpContainer />
			<cfelse>
				<!--- Item is already an array: --->
				
			</cfif>
			<cfif arrayLen(axml.XmlChildren[i].XmlChildren) gt 0>
					<!--- recurse call: get complex item: --->
					<cfset astr[n][arrayLen(astr[n])+1] = ConvertXmlToStruct(axml.XmlChildren[i], structNew()) />
				<cfelse>
					<!--- else: assign node value as last element of array: --->
					<cfset astr[n][arrayLen(astr[n])+1] = axml.XmlChildren[i].XmlText />
			</cfif>
		<cfelse>
			<!---
				This is not a struct. This may be first tag with some name.
				This may also be one and only tag with this name.
			--->
			<!---
					If context child node has child nodes (which means it will be complex type): --->
			<cfif arrayLen(axml.XmlChildren[i].XmlChildren) gt 0>
				<!--- recurse call: get complex item: --->
				<cfset astr[n] = ConvertXmlToStruct(axml.XmlChildren[i], structNew()) />
			<cfelse>
				<!--- else: assign node value as last element of array: --->
				<!--- if there are any attributes on this element--->
				<cfif IsStruct(aXml.XmlChildren[i].XmlAttributes) AND StructCount(aXml.XmlChildren[i].XmlAttributes) GT 0>
					<!--- assign the text --->
					<cfset astr[n] = axml.XmlChildren[i].XmlText />
						<!--- check if there are no attributes with xmlns: , we dont want namespaces to be in the response--->
					 <cfset attrib_list = StructKeylist(axml.XmlChildren[i].XmlAttributes) />
					 <cfloop from="1" to="#listLen(attrib_list)#" index="attrib">
						 <cfif ListgetAt(attrib_list,attrib) CONTAINS "xmlns:">
							 <!--- remove any namespace attributes--->
							<cfset Structdelete(axml.XmlChildren[i].XmlAttributes, listgetAt(attrib_list,attrib))>
						 </cfif>
					 </cfloop>
					 <!--- if there are any atributes left, append them to the response--->
					 <cfif StructCount(axml.XmlChildren[i].XmlAttributes) GT 0>
						 <cfset astr[n&'_attributes'] = axml.XmlChildren[i].XmlAttributes />
					</cfif>
				<cfelse>
					 <cfset astr[n] = axml.XmlChildren[i].XmlText />
				</cfif>
			</cfif>
		</cfif>
	</cfloop>
	<!--- return struct: --->
	<cfreturn astr />
</cffunction>
<cfscript>
/**
 * Sorts an array of structures based on a key in the structures.
 * 
 * @param aofS      Array of structures. 
 * @param key      Key to sort by. 
 * @param sortOrder      Order to sort by, asc or desc. 
 * @param sortType      Text, textnocase, or numeric. 
 * @param delim      Delimiter used for temporary data storage. Must not exist in data. Defaults to a period. 
 * @return Returns a sorted array. 
 * @author Nathan Dintenfass (nathan@changemedia.com) 
 * @version 1, December 10, 2001 
 */
function arrayOfStructsSort(aOfS,key){
        //by default we'll use an ascending sort
        var sortOrder = "asc";        
        //by default, we'll use a textnocase sort
        var sortType = "textnocase";
        //by default, use ascii character 30 as the delim
        var delim = ".";
        //make an array to hold the sort stuff
        var sortArray = arraynew(1);
        //make an array to return
        var returnArray = arraynew(1);
        //grab the number of elements in the array (used in the loops)
        var count = arrayLen(aOfS);
        //make a variable to use in the loop
        var ii = 1;
        //if there is a 3rd argument, set the sortOrder
        if(arraylen(arguments) GT 2)
            sortOrder = arguments[3];
        //if there is a 4th argument, set the sortType
        if(arraylen(arguments) GT 3)
            sortType = arguments[4];
        //if there is a 5th argument, set the delim
        if(arraylen(arguments) GT 4)
            delim = arguments[5];
        //loop over the array of structs, building the sortArray
        for(ii = 1; ii lte count; ii = ii + 1)
            sortArray[ii] = aOfS[ii][key] & delim & ii;
        //now sort the array
        arraySort(sortArray,sortType,sortOrder);
        //now build the return array
        for(ii = 1; ii lte count; ii = ii + 1)
            returnArray[ii] = aOfS[listLast(sortArray[ii],delim)];
        //return the array
        return returnArray;
}
</cfscript>
<!--- Get Full Column List --->
<cfquery name="qData" datasource="#session.dbsource#">
    	SELECT	cci.*, sav.defsDate
        <cfif hasHWData EQ true>
        	, hw.mpa_Model_Name, hw.mpa_Model_Identifier
        </cfif>
        FROM	mp_clients_view cci
        LEFT 	JOIN savav_info sav 
        ON cci.cuuid = sav.cuuid
        <cfif hasHWData EQ true>
        	LEFT JOIN mpi_SPHardwareOverview hw ON
        	cci.cuuid = hw.cuuid
        </cfif>
		Limit 1
</cfquery>

<cfset queryColumnList = "#qData.columnlist#">
<cfset _xmlConfData = #genColModelForTable(listtoArray(qData.columnlist),'Hello')#>
<cfset _xmlConfDataDefault = _xmlConfData>
<cfset _xmlUsrConfFile = #Expandpath("./includes/settings/"&session.Username&"/"&jqGridInfoData&".xml")#>
<cfset _xmlConfFile = #Expandpath("./includes/settings/"&jqGridInfoData&".xml")#>
<cfset _validConfData = "">
<cfset _validXML = true>
<!--- Read and Validate XML File Data --->
<cfif FileExists(_xmlUsrConfFile)>
	<cffile action="read" file="#_xmlUsrConfFile#" variable="_xmlConfData">
	<cftry>
		<cfset _xV = XmlValidate(_xmlConfData)>
		<cfset _validConfData = _xmlConfData>
	<cfcatch>
		<cfset _validXML = false>
	</cfcatch>
	</cftry>
<cfelseif FileExists(_xmlConfFile)>
	<cffile action="read" file="#_xmlConfFile#" variable="_xmlConfData">
	<cftry>
		<cfset _xV = XmlValidate(_xmlConfData)>
		<cfset _validConfData = _xmlConfData>
	<cfcatch>
		<cfset _validXML = false>
	</cfcatch>
	</cftry>
<cfelse>
	<cffile action="write" file="#_xmlConfFile#" OUTPUT="#_xmlConfData#" NAMECONFLICT="overwrite">
	<cfset _validConfData = _xmlConfData>
</cfif>
<cfif _validXML EQ false>
	<cffile action="write" file="#_xmlConfFile#" OUTPUT="#_xmlConfDataDefault#" NAMECONFLICT="overwrite">
	<cfset _validConfData = _xmlConfDataDefault>
</cfif>	

<cfset columnsStruct = "#ConvertXmlToStruct(ToString(_validConfData), structnew())#">
<cfset sortedColsStruct = #arrayOfStructsSort(columnsStruct.Columns.Column,"order","asc","numeric")#>

<script src="./_assets/js/jquery/addons/contextmenu.r2/jquery.contextmenu.r2.js" type="text/javascript"></script>

<SCRIPT LANGUAGE=javascript>
<!--
function dateDifference(strDate1,strDate2){
     datDate1= Date.parse(strDate1);
     datDate2= Date.parse(strDate2);
     return ((datDate2-datDate1)/(24*60*60*1000)); 
}
//-->
</SCRIPT>

<script type="text/javascript">	
	function loadContent(param, id) {
		$("#dialog").load("./includes/available_patches_apple_description.cfm?pid="+id);
		$("#dialog").dialog(
		 	{
			bgiframe: false,
			height: 300,
			width: 600,
			modal: true
			}
		); 
		$("#dialog").dialog('open');
	}
</script>
<!--- 
--->
<script type="text/javascript">
	var eventsMenu = {
		bindings: {
			'HardwareOverview': function(t) {
				popUpInvWindow('/admin/includes/inventory/application_info.cfm?type=hardwareoverview&cuuid='+t.id+'','Client Info');
			},
			'SoftwareOverview': function(t) {
				popUpInvWindow('/admin/includes/inventory/application_info.cfm?type=systemoverview&cuuid='+t.id+'','Client Info');
			},
			'NetworkOverview': function(t) {
				popUpInvWindow('/admin/includes/inventory/application_info.cfm?type=networkoverview&cuuid='+t.id+'','Client Info');
			},
			'Applications': function(t) {
				popUpInvWindow('/admin/includes/inventory/application_info.cfm?type=applications&cuuid='+t.id+'','Client Info');
			},
			'ApplicationUsage': function(t) {
				popUpInvWindow('/admin/includes/inventory/application_info.cfm?type=applicationusage&cuuid='+t.id+'','Client Info');
			},
			'DirectoryService': function(t) {
				popUpInvWindow('/admin/includes/inventory/application_info.cfm?type=directoryoverview&cuuid='+t.id+'','Client Info');
			},
			'Frameworks': function(t) {
				popUpInvWindow('/admin/includes/inventory/application_info.cfm?type=frameworks&cuuid='+t.id+'','Client Info');
			},
			'InternetPlugins': function(t) {
				popUpInvWindow('/admin/includes/inventory/application_info.cfm?type=internetplugins&cuuid='+t.id+'','Client Info');
			},
			'ClientTasks': function(t) {
				popUpInvWindow('/admin/includes/inventory/application_info.cfm?type=clienttasks&cuuid='+t.id+'','Client Info');
			},
			'DiskInfo': function(t) {
				popUpInvWindow('./includes/inventory/application_info.cfm?type=diskinfo&cuuid='+t.id+'','Client Info');
			},
			'SWInstalls': function(t) {
				popUpInvWindow('/admin/includes/inventory/application_info.cfm?type=swinstalls&cuuid='+t.id+'','Client Info');
			}
		}
	};

	$(document).ready(function()
		{
			var lastsel = -1;
			$("#list").jqGrid(
			{
				url:'./includes/client_groups.cfc?method=getClientsForGroup&clientgroup=<cfoutput>#ClientGroupName#</cfoutput>', //CFC that will return the users
				datatype: 'json', //We specify that the datatype we will be using will be JSON
				ajaxGridOptions:{
					type: "POST",
					url: "./includes/client_groups.cfc?method=getClientsForGroup&clientgroup=<cfoutput>#ClientGroupName#</cfoutput>",
				},
				<cfif isDefined("fID")>
				postData: {
					/* method: '', */
					searchType:true,
					searchField: function() { return "<cfoutput>#fID#</cfoutput>"; },
					searchString: function() { return "<cfoutput>#fDD#</cfoutput>"; },
					searchOper: function() { return "cn"; },
					orderedCols: function() { return "<cfoutput>#itemListFromStuctArray(sortedColsStruct,'name')#</cfoutput>"; },
				},
				<cfelse>
				postData: {
					orderedCols: function() { return "<cfoutput>#itemListFromStuctArray(sortedColsStruct,'name')#</cfoutput>"; }
				},
				</cfif>
				<cfoutput>#genColModelHeaderForJS(sortedColsStruct)#</cfoutput>,
				<cfoutput>#genColModelDataForJS(sortedColsStruct)#</cfoutput>,
				altRows:true,
				pager: jQuery('#pager'), //The div we have specified, tells jqGrid where to put the pager
				rowNum:30, //Number of records we want to show per page
				rowList:[10,20,30,50,100], //Row List, to allow user to select how many rows they want to see per page
				sortorder: "desc", //Default sort order
				sortname: "hostname", //Default sort column
				viewrecords: true, //Shows the nice message on the pager
				imgpath: '/', //Image path for prev/next etc images
				caption: '<cfoutput><cfif #ClientGroupName# EQ "x">All<cfelse>#ClientGroupName#</cfif></cfoutput> - Clients', //Grid Name
				height:'auto', //I like auto, so there is no blank space between. Using a fixed height can mean either a scrollbar or a blank space before the pager
				recordtext: "View {0} - {1} of {2} Records",
				pgtext: "Page {0} of {1}",
				pginput:true,
				width:980,
				hidegrid:false,
				multiselect: true,
				multiboxonly: true,
				editurl:"./includes/client_groups.cfc?method=editClientsForGroup",//Not used right now.
				toolbar:[false,"top"],//Shows the toolbar at the top. I will decide if I need to put anything in there later.
				//The JSON reader. This defines what the JSON data returned from the CFC should look like
				afterInsertRow: function(rowid, rowdata, rowelem) {
                	$('#' + rowid).contextMenu('MenuJqGrid', eventsMenu);
                },
				loadComplete: function(){ 
					var today = new Date();
					var ids = jQuery("#list").getDataIDs();  
					for(var i=0;i<ids.length;i++){ 
						var cl = ids[i];
						var avs = jQuery("#list").getCell(cl,'defsDate');
						info = "<input type='image' style='padding-left:4px;' onclick=popUpWindow('./includes/list_client_group_client_info.cfm?cuuid="+ids[i]+"'); src='./_assets/images/jqGrid/info_16.png' height='16' width='16' align='texttop' TITLE='Client Properties'>";					
						/* Antivirus Config */
						if (avs == "")
						{
							av = "<input type='image' style='padding-left:4px;' onclick=popUpWindow('./includes/list_client_group_client_avinfo.cfm?cuuid="+cl+"'); src='./_assets/images/av_red2.png' height='16' width='16' align='texttop' TITLE='AV Properties'>";
						}
						else
						{
							av = "<input type='image' style='padding-left:4px;' onclick=popUpWindow('./includes/list_client_group_client_avinfo.cfm?cuuid="+cl+"'); src='./_assets/images/av_green2.png' height='16' width='16' align='texttop' TITLE='AV Properties'>";
						}
						/* Calculate Date Info for Client Indicator */
						var dt = jQuery("#list").getCell(cl,'mdate');
						var ldate = new Date(dt);
						if ( dateDifference(ldate,today) >= 7 && dateDifference(ldate,today) <= 14)
						{
							/* jQuery('#list').setCell(ids[i],'mdate','',{'background': '#FFCC00'}); */
							$(this).jqGrid('setRowData', ids[i], false, {'background': '#FFCC00'});
						}
						else if ( dateDifference(ldate,today) >= 15 )
						{
							/* jQuery('#list').setCell(ids[i],'mdate','',{'background': 'red'}); */
							$(this).jqGrid('setRowData', ids[i], false, {'background': 'red'});
						}
						jQuery("#list").setRowData(ids[i],{cuuid:info,defsDate:av})
					} 
				},
				onSelectRow: function(id){
					/* This section of code fixes the highlight issues, with altRows */
					if(id && id!==lastsel){
						var xyz = $("#list").getDataIDs().indexOf(lastsel);
						if (xyz%2 != 0)
						{
						  $('#'+lastsel).addClass('ui-priority-secondary');	
						} 							 

					  $('#list').jqGrid('restoreRow',lastsel);
					  lastsel=id;
					}
					$('#'+id).removeClass('ui-priority-secondary');
				},
				jsonReader: {
					total: "total",
					page: "page",
					records:"records",
					root: "rows",
					userdata: "userdata",
					cell: "",
					id: "0"
					}
				}
			);
			
			
			
			$("#list").jqGrid('navGrid',"#pager",{edit:false,add:false,del:true,excel:true});
			/*
			$('#list').jqGrid('navButtonAdd', '#pager',
			{   
				caption: "Columns",
				title: "Reorder Columns",
				onClickButton: function() { jQuery("#list").jqGrid('columnChooser') 
				} 
			});
			*/
			$('#list').jqGrid('navButtonAdd', '#pager',
			{   
				caption: "Columns",
				title: "Edit Columns",
				onClickButton: function() {
					window.location.href = './index.cfm?GridConfig&data=<cfoutput>#Encrypt(jqGridInfoData,session.usrKey)#</cfoutput>';			
				} 
			});
			$('#list').jqGrid ('navSeparatorAdd','#pager')
			$('#list').jqGrid ('navButtonAdd', '#pager', {
				id:         "export_grid",
				caption:    "Export (CSV)",
				title:      "Export the grid",
				buttonicon: "ui-icon-disk",
				onClickButton:  function () {
					window.location.href = './includes/client_groups_export.cfm?clientgroup=<cfoutput>#ClientGroupName#</cfoutput>';
				}
			});
		}
	);	
</script>
<script type="text/javascript">	
	var popUpWin=0;
	function popUpWindow(URLStr, WindowName)
	{
	 popUpWin = window.open(URLStr, WindowName, 'width=560,height=680,menubar=no,resizable=yes,scrollbars=yes,toolbar=no,top=90,left=90',false);
	}
	var popUpInvWin=0;
	function popUpInvWindow(URLStr, WindowName)
	{
	 popUpInvWin = window.open(URLStr, WindowName, 'width=800,height=600,menubar=no,resizable=yes,scrollbars=yes,toolbar=no,top=90,left=90',false);
	}
</script>

<table id="list" cellpadding="0" cellspacing="0" style="font-size:10px;"></table>
<div id="pager" style="text-align:center;font-size:11px;"></div>
<div id="dialog" title="Detailed Patch Information" style="text-align:left;" class="ui-dialog-titlebar"></div>
<div class="contextMenu" id="MenuJqGrid">  
     <ul>
        <li id="HardwareOverview" style="text-align:left">
            <img src="./_assets/images/icons/report.png" />Hardware Overview
        </li>
        <li id="SoftwareOverview" style="text-align:left">
            <img src="./_assets/images/icons/report.png" />Software Overview
        </li>
        <li id="NetworkOverview" style="text-align:left">
            <img src="./_assets/images/icons/report.png" />Network Overview
        </li>
        <li id="Applications" style="text-align:left">
            <img src="./_assets/images/icons/report.png" />Applications
        </li>
        <li id="ApplicationUsage" style="text-align:left">
            <img src="./_assets/images/icons/report.png" />Application Usage
        </li>
		<li id="DirectoryService" style="text-align:left">
            <img src="./_assets/images/icons/report.png" />Directory Service
        </li>
		<li id="Frameworks" style="text-align:left">
            <img src="./_assets/images/icons/report.png" />Frameworks
        </li>
		<li id="InternetPlugins" style="text-align:left">
            <img src="./_assets/images/icons/report.png" />Internet Plugins
        </li>
        <li id="ClientTasks" style="text-align:left">
            <img src="./_assets/images/icons/report.png" />Client Tasks
        </li>
		<li id="SWInstalls" style="text-align:left">
            <img src="./_assets/images/icons/report.png" />Installed Software Results
        </li>
		<li id="DiskInfo" style="text-align:left">
            <img src="./_assets/images/icons/report.png" />Disk Usage
        </li>
    </ul>
</div>
<p>&nbsp;</p>
<table class="generictable" width="330">
	<tr>
    	<td align="center">Client Check-in Status</td>
    </tr>
</table>    
<table class="resultsListTable" width="330">
	<tr>
    <td class="normal" width="110"><b>Normal</b></td>
    <td class="warn" width="110"><b>Warning</b></td>
    <td class="alert" width="110"><b>Alert</b></td>
    </tr>
    <tr>
    <td class="normal">0 - 7 Days</td>
    <td class="warn">7 - 14 Days</td>
    <td class="alert">15 or more Days</td>
    </tr>
</table>


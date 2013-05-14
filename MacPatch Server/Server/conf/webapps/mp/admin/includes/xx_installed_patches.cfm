
<script type="text/javascript">
	$(document).ready(function()
		{
			var mygrid = $("#list").jqGrid(
			{
				url:'./includes/xx_installed_patches.cfc?method=getInstalledPatches', //CFC that will return the users
				datatype: 'json', //We specify that the datatype we will be using will be JSON
				colNames:['', '','Patch', 'HostName', 'Client Group', 'Install Date'],
				colModel :[ 
				  {name:'id', index:'id', hidden: true},
				  {name:'cuuid', index:'cuuid', hidden: true},
				  {name:'patch', index:'patch', width:140}, 
				  {name:'hostname', index:'hostname', width:200},
				  {name:'domain', index:'domain', width:100}, 
				  {name:'idate', index:'idate', width:140}
				],
				emptyrecords: "No records to view",
				altRows:true,
				pager: jQuery('#pager'), //The div we have specified, tells jqGrid where to put the pager
				rowNum:30, //Number of records we want to show per page
				rowList:[10,20,30,50,100], //Row List, to allow user to select how many rows they want to see per page
				sortorder: "desc", //Default sort order
				sortname: "idate", //Default sort column
				viewrecords: true, //Shows the nice message on the pager
				imgpath: '/', //Image path for prev/next etc images
				caption: 'Installed Patches', //Grid Name
				height:'auto', //I like auto, so there is no blank space between. Using a fixed height can mean either a scrollbar or a blank space before the pager
				recordtext: "Show {0} - {1} of {2} Records",
				pgtext: "Page {0} of {1}",
				pginput:true,
				width:980,
				editurl:"includes/xx_installed_patches.cfc?method=addEditInstalledPatches",//Not used right now.
				toppager:false,
				hidegrid:false,
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
			$("#list").jqGrid('navGrid',"#pager",{edit:false,add:false,del:false},
			   {}, // default settings for edit
			   {}, // default settings for add
			   {}, // delete
			   { sopt:['cn','bw','eq','ne','lt','gt','ew'], closeOnEscape: true, multipleSearch: true, closeAfterSearch: true }, // search options
			   {}
			);
			$("#list").navButtonAdd("#pager",{caption:"",title:"Toggle Search Toolbar", buttonicon:'ui-icon-pin-s', onClickButton:function(){ mygrid[0].toggleToolbar() } });
			$("#list").jqGrid('filterToolbar',{stringResult: true, searchOnEnter: true, defaultSearch: 'cn'}); 
			$("#list").jqGrid('toggleToolbar'); 
		}
	);
</script>
<table id="list" cellpadding="0" cellspacing="0" style="font-size:11px;"></table>
<div id="pager" style="color:#000;"></div>


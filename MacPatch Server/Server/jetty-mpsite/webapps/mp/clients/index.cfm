<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<html>
<head>
	<title>MacPatch Client Downloads</title>
	<link href="/css/login.css" rel="stylesheet" type="text/css" />
</head>
<body>
	<!---
	<div id="headermain">
    	<div id="headerbanner">
    		<table cellpadding="0" cellspacing="0" width="1100">
                <tr>
                  <td width="10">
                    <img src="../assets/images/BannerLeftCorner.gif">
                  </td>
                  <td valign="top" bgcolor="#000000">
                    <img src="../assets/images/macpatchbanner.jpg">
                  </td>
                  <td align="right" bgcolor="#000000" valign="bottom">  
                    <a href="/">Admin Login</a>
                  </td>
                    <td width="10">
                    <img src="../assets/images/BannerRightCorner.gif">
                    </td>
                </tr>
            </table>
    	</div>
        <div id="headermenu">
        	<table cellpadding="0" cellspacing="0" width="1100" background="../assets/images/article-title-bg-apple.png">
                <tr height="30">
                	<td><a href="/clients" class="headermenuIndentFirst">Client Download</a>|<a href="http://<cfoutput>#CGI.SERVER_NAME#</cfoutput>/" class="headermenuIndentMiddle">Home</a></td>
                </tr>
            </table>
        </div>
        <div id="headerStatusBar">
            &nbsp;
        </div>
    </div>
	<!--- Main Body Section --->
    <div id="bodymain">
        <div id="bodycontainer" style="height:600px;">
		<br>
		<cfset BaseDir = #Expandpath(".")#>
		<cfdirectory action="list" sort="datelastmodified Desc" directory="/Library/MacPatch/Content/Web/clients" name="getdir" filter="*.zip">
        <span class="style4">Download Client Software...</span><br>
        <div id="normalize">
          <ul>
            
            <table id="files">
            	<tr>
                <th>Name</th>
                <th>Size</th>
                <th>Mod date</th>
                </tr>
                <cfoutput query="getdir">
                <tr>
                	<td><a href="/mp-content/clients/#name#">#Name#</a></td>
                    <td>#Round(Size/1024/1024)#MB</td>
                    <td>#DateFormat(dateLastModified,"yyyy-mm-dd")# #TimeFormat(dateLastModified,"HH:mm:ss")#</td>
                </tr>
                </cfoutput>
                </table>
          </ul>
        </div> 
    	</div> <!--- bodycontainer --->
	</div> <!--- container --->
	--->
    <div id="layout" class="layout">
	<div class="login_dialog">
		<h1>MacPatch Client Downloads</h1>
		<div class="icon">
        	<div class="img"></div>
        </div>
		<p>&nbsp;</p>
		<cfset BaseDir = #Expandpath(".")#>
		<cfdirectory action="list" sort="datelastmodified Desc" directory="/Library/MacPatch/Content/Web/clients" name="getdir" filter="*.zip">
        <div id="normalize">
            <ul>
            <table id="files" cellpadding="4px">
            <tr>
            	<th>Name</th>
            	<th>Size</th>
            	<th>Mod date</th>
            </tr>
            <cfoutput query="getdir">
            <tr>
                <td><a href="/mp-content/clients/#name#">#Name#</a></td>
                <td>#Round(Size/1024/1024)#MB</td>
                <td>#DateFormat(dateLastModified,"yyyy-mm-dd")# #TimeFormat(dateLastModified,"HH:mm:ss")#</td>
            </tr>
            </cfoutput>
            </table>
            </ul>
		</div>
        <hr />
        <div style="margin-top:10px; margin-bottom:10px; text-align:center;">
        <a href="https://<cfoutput>#CGI.SERVER_NAME#</cfoutput>/admin" class="headermenuIndentMiddle">Admin Console Login</a>
        </div>
	</div>
</div>
</body>
</html>

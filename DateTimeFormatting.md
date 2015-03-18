# Date/Time Formatting #

To change date/time representation in history grid.

### How to edit database ###

See AdditionalOptions
<br>
You will have to add DateTimeFormat string key.<br>
<br>
<h3>Simple examples</h3>

January 2, 2006 3:05:44<br>
<br>
<table><thead><th>DateTimeFormat value</th><th>Result</th><th>Comment</th></thead><tbody>
<tr><td>c </td><td>02/01/2006 3:05:44</td><td>Date and time format is default system format</td></tr>
<tr><td>ddd, mmm d, yy</td><td>Mon, Jan 2, 06</td><td>  </td></tr>
<tr><td>dd/mm/yyyy hh:nn:ss</td><td>02/01/2006 03:05:44</td><td>  </td></tr>
<tr><td>dddd, d of mmmm, yyyy</td><td>Monday, 2 of January, 2006</td><td>  </td></tr>
<tr><td>hh:nn am/pm</td><td>03:05 am</td><td>am/pm translates time to 12-hour time</td></tr>
<tr><td>h:n:s a/p</td><td>3:5:44 a</td><td>a/p translates time to 12-hour time</td></tr></tbody></table>

For explanation and full list of commands read Format section<br>
<br>
<h3>Format</h3>

Here is the full list of variables with examples given for date and time: January 2, 2006 3:05:44<br>
<br>
<table><thead><th>String</th><th>Meaning</th><th>Example</th></thead><tbody>
<tr><td>y </td><td>Year last 2 digits</td><td>06</td></tr>
<tr><td>yy</td><td>Year last 2 digits</td><td>06</td></tr>
<tr><td>yyyy</td><td>Year as 4 digits</td><td>2006</td></tr>
<tr><td>m </td><td>Month number, without leading zero</td><td>1 </td></tr>
<tr><td>mm</td><td>Month number with leading zero</td><td>01</td></tr>
<tr><td>mmm</td><td>Short month name</td><td>Jan</td></tr>
<tr><td>mmmm</td><td>Full month name</td><td>January</td></tr>
<tr><td>d </td><td>Day number, without leading zero</td><td>2 </td></tr>
<tr><td>dd</td><td>Day number with leading zero</td><td>02</td></tr>
<tr><td>ddd</td><td>Short day name</td><td>Mon</td></tr>
<tr><td>dddd</td><td>Full day name</td><td>Monday</td></tr>
<tr><td>ddddd</td><td>Date as short date format (system-dependent)</td><td>02/01/2006</td></tr>
<tr><td>dddddd</td><td>Date as long date format (system-dependent)</td><td>02 January 2006</td></tr>
<tr><td>h </td><td>Hour, without leading zero</td><td>3 </td></tr>
<tr><td>hh</td><td>Hour with leading zero</td><td>03</td></tr>
<tr><td>n </td><td>Minute, without leading zero</td><td>5 </td></tr>
<tr><td>nn</td><td>Minute with leading zero</td><td>05</td></tr>
<tr><td>s </td><td>Second, without leading zero</td><td>44</td></tr>
<tr><td>ss</td><td>Second with leading zero</td><td>44</td></tr>
<tr><td>z </td><td>Msec, without leading zero</td><td>21</td></tr>
<tr><td>zzz</td><td>MSec as 3 digits</td><td>021</td></tr>
<tr><td>am/pm</td><td>Sets hour to 12-hour time and writes am or pm</td><td>am</td></tr>
<tr><td>a/p</td><td>Sets hour to 12-hour time and writes a or p</td><td>a </td></tr>
<tr><td>t </td><td>Short time format (system-dependent)</td><td>3:05</td></tr>
<tr><td>tt</td><td>Long time format (system-dependent)</td><td>3:05:44</td></tr>
<tr><td>c </td><td>Short date format + long time format (system-dependent)</td><td>02/01/2006 3:05:44</td></tr>
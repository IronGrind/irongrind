import {readFileSync,writeFileSync} from 'node:fs';
const diagram=readFileSync('Documentations/Chapter 3 Diagrams/05-gym-erd-user-supplied.svg','utf8');
const groups=[
 ['Account and membership',[
 ['profiles.id','auth.users.id','Connects the IronGrind profile to the user’s sign-in account. The profile stores application details such as the role.'],
 ['membership_applications.auth_user_id','auth.users.id','Identifies the sign-in account associated with the application.'],
 ['membership_applications.reviewed_by','profiles.id','Identifies the profile of the account that reviewed the application, when a reviewer is recorded.'],
 ['members.application_id','membership_applications.id','Lets us find the original application associated with creating the member record.'],
 ['members.auth_user_id','auth.users.id','Links the gym member record to a sign-in account when one is linked.'],
 ['membership_applications.member_id','members.id','Identifies the member a request concerns. For example, a renewal request can refer to an existing member.'],
 ['membership_history.member_id','members.id','Identifies whose membership changed. One member can have several history records.'],
 ['membership_history.recorded_by','auth.users.id','Identifies the account that recorded the membership change, when that information is available.'],
 ]],
 ['Attendance and phone scanning',[
 ['attendance.member_id','members.id','Tells us whose visit was recorded. One member can have many attendance records.'],
 ['attendance.recorded_by','auth.users.id','Identifies the account that recorded the check-in, when that information is available.'],
 ['attendance.checked_out_by','auth.users.id','Identifies the account that recorded the check-out, when that information is available.'],
 ['mobile_attendance_pairing_policy.updated_by','auth.users.id','Identifies the account that updated the phone-pairing settings, when recorded.'],
 ['mobile_attendance_scan_sessions.created_by','auth.users.id','Identifies the account that created the scanner session.'],
 ['mobile_attendance_scan_events.session_id','mobile_attendance_scan_sessions.id','Tells us which scanner session a recorded event belongs to. One session can have multiple events.'],
 ]],
 ['Sales, reports, and audit',[
 ['sales.member_id','members.id','Identifies the member associated with the sale. This link is optional.'],
 ['sales.processed_by','auth.users.id','Identifies the account that processed the sale, when recorded.'],
 ['sale_items.sale_id','sales.id','Tells us which checkout the item belongs to. The shirt and supplement in one checkout share the same sale ID.'],
 ['sale_items.product_id','products.id','Identifies the catalog product associated with the sale item when a product is linked.'],
 ['generated_reports.generated_by','profiles.id','Identifies the profile that generated the saved report. One profile can have several reports.'],
 ]],
];
const intro=`<h1>Before you trace the lines</h1>
<p class="cue"><b>Point to</b> the whole Figure 5 first. Then use the attendance and members tables to introduce the labels.</p>
<blockquote>“Figure 5 shows how IronGrind, our web-based gym management system, stores records across 13 public tables. Each box is a table. The fields inside it are columns, and each row in the database is one record, such as one gym visit.”</blockquote>
<dl>
<dt><code>id</code> and PK</dt><dd><b>Point to <code>members.id</code>.</b> “A primary key uniquely identifies a row. This ID identifies one member, even if two members have the same name.”</dd>
<dt>FK and <code>member_id</code></dt><dd><b>Point to <code>attendance.member_id</code>, then <code>members.id</code>.</b> “A foreign key references a related record. This field holds the ID of the member whose visit was recorded.”</dd>
<dt>UQ and data types</dt><dd><b>Point to <code>profiles.username</code> and the type column.</b> “UQ means the field has a uniqueness rule. The type tells us what kind of value it holds. A UUID is an identifier. A field such as username holds text.”</dd>
<dt>Other fields</dt><dd><b>Point to <code>members.plan</code> and <code>attendance.time_in</code>.</b> “These fields describe the record. The plan tells us the member’s current plan, and time in tells us when the visit began.”</dd>
<dt>Line symbols</dt><dd><b>Point to the legend.</b> “A solid line connects public tables. A dashed line connects to the managed Auth table. The crow’s foot shows the many side. A circle shows that a relationship end is optional.”</dd>
</dl>
<p class="cue"><b>Transition</b> “Now I’ll follow each connector separately, from the foreign key to the key it references.”</p>`;
let index=0;
const connectorPages=groups.map(([title,rows])=>`<h1>${title}</h1><p class="cue">Start at the first field. Follow that connector and stop at the second field before moving to the next item.</p>`+
rows.map(([from,to,answer])=>`<article><b class="num">${String(++index).padStart(2,'0')}</b><div><h2><code>${from}</code> → <code>${to}</code></h2><p>“${answer}”</p></div></article>`).join('')+
(title.startsWith('Sales')?`<h2>Activity logs</h2><p class="cue"><b>Point to</b> <code>activity_logs.action</code> and <code>occurred_at</code>.</p><p>“This table records actions and their timestamps. The actor information helps describe an event. Figure 5 does not show a declared foreign-key connector for this table.”</p>`:''));
if(index!==19)throw Error('Expected 19 connector explanations');
const pages=[intro,`<h1>Figure 5 · Full reference</h1><p class="cue">Keep this page beside the pointing cues. Follow the connector to its endpoint when lines cross.</p><div class="diagram">${diagram}</div>`,...connectorPages];
const body=pages.map((p,i)=>`<section><header>IRONGRIND / ERD DEFENSE GUIDE <span>${i+1} / ${pages.length}</span></header>${p}</section>`).join('');
writeFileSync('.erd-connector-print/guide.html',`<!doctype html><html lang="en"><meta charset="utf-8"><title>IronGrind ERD Line-by-Line Guide</title><style>
@page{size:A4;margin:13mm}*{box-sizing:border-box}body{margin:0;color:#103b83;font:11pt/1.38 Arial,sans-serif;print-color-adjust:exact}section{break-after:page}section:last-child{break-after:auto}header{font-size:9pt;letter-spacing:.07em;font-weight:bold;border-bottom:1px solid #5477a8;padding-bottom:2mm}header span{float:right}h1{font-size:22pt;line-height:1.13;margin:5mm 0 3mm}.cue,blockquote{margin:0 0 3mm;background:#eef4fc;border-left:2px solid #3566a8;padding:2mm 3mm}h2{font-size:11.5pt;margin:0 0 1mm;overflow-wrap:anywhere}p{margin:0 0 2mm}article{display:grid;grid-template-columns:9mm 1fr;gap:1mm;border-bottom:1px solid #b9c9e1;padding:2mm 0;break-inside:avoid}article p{margin:0}.num{font-size:10pt}code{font-family:Consolas,monospace}dt{font-weight:bold;margin:3mm 0 1mm}dd{margin:0 0 2mm}.diagram svg{display:block;width:100%;height:auto}.diagram svg text{fill:#103b83!important}
</style>${body}</html>`);

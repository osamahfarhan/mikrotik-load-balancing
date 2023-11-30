{
#----------- الخطوط بردج 
#----------- اصدار الميكروتيك V6
#----------- اكتب سرعة الخطوط فقط
#----------- 2,2,4,4,8,8 امسح الارقام واكتب سرعة الخط مع فاصلة مثل كذا
:local PPP (2,2,4,4,8,8);
#----------- اكتب منفذ خروج النت 
:local OutName ("ether10");
#----------- بعد تنفيذ الاسكربت ادخل على خطوط البردج 
#----------- وغير اسم الامستخدم وكلمة السر حق الخطوط
#---------------------------
:if ([:len [/interface bridge port find where interface=$OutName]]>0) do={:set $OutName [/interface bridge port get ([find where interface=$OutName]->0) bridge];} 
:do {/interface list add comment="Eng-Osamah" name=DMGLAN;} on-error={};
:do {/interface list member add interface=$OutName comment="Eng-Osamah" list=DMGLAN;} on-error={};
:do {/interface list add name=("pppoe-out") comment="Eng-Osamah";} on-error={};
:do {/interface list add comment="Eng-Osamah" include=("pppoe-out") name=DMGWAN;} on-error={};
:local ARR [:toarray ""];:local LINES ([:len $PPP]);:local Total 0;:local Min 10000;:local Max 0;:local ALLOUT;
:foreach i,j in=$PPP do={
    :if ($j=0) do={:error "not correct number";} 
    :set $Total ($Total+$j);
    :if ($j<$Min) do={:set $Min $j;};
    :if ($j>$Max) do={:set $Max $j;};
    :local N [/interface ethernet get [find where default-name=("ether".($i+1))] name];
    :do {/interface list member add interface=$N comment="Eng-Osamah" list=DMGWAN;} on-error={};
    :do {/interface list member add interface=("pppoe-out-".($i+1)) comment="Eng-Osamah" list=("pppoe-out");} on-error={};
    :do {/interface pppoe-client add disabled=yes interface=$N comment="Eng-Osamah" keepalive-timeout=30 name=("pppoe-out-".($i+1)) user="USERNAME"  password="PASSWORE";} on-error={};
    :set $ALLOUT ($ALLOUT,("pppoe-out-".($i+1)));
}
:if ($Total=0) do={:error "not correct number";} 
:local Con (($Total/$Min));
:local ConN 0;
:do {/ip route add disabled=yes gateway=$ALLOUT comment="Eng-Osamah";} on-error={};
/ip firewall nat add action=masquerade disabled=yes chain=srcnat out-interface-list=("pppoe-out") comment="Eng-Osamah";
/ip firewall nat add action=masquerade disabled=yes chain=srcnat out-interface-list=DMGWAN comment="Eng-Osamah";
:foreach i,j in=$PPP do={
:local N ($j/$Min);:if ($N=0) do={:set $N 1;};
:for k from=1 to=$N do={/ip firewall mangle add comment="Eng-Osamah" disabled=yes action=mark-connection chain=prerouting connection-mark=no-mark dst-address-type=!local in-interface-list=DMGLAN new-connection-mark=("C_".($i+1)) passthrough=yes per-connection-classifier=("both-addresses-and-ports:$Con/$ConN");:set $ConN ($ConN+1);};
:if ([:len $PPP]=($i+1)) do={/ip firewall mangle add comment="Eng-Osamah" disabled=yes action=mark-connection chain=prerouting connection-mark=no-mark dst-address-type=!local in-interface-list=DMGLAN new-connection-mark=("C_".($i+1)) passthrough=yes;:set $ConN ($ConN+1);};
/ip firewall mangle add comment="Eng-Osamah" disabled=yes action=mark-routing chain=prerouting connection-mark=("C_".($i+1)) in-interface-list=DMGLAN new-routing-mark=("R_".($i+1)) passthrough=no;
/ip route add comment="Eng-Osamah" disabled=yes gateway=("pppoe-out-".($i+1)) routing-mark=("R_".($i+1));
};
/ip route enable  [find where comment="Eng-Osamah"];
/ip firewall nat enable [find where comment="Eng-Osamah"];
/ip firewall mangle enable [find where comment="Eng-Osamah"];
/interface pppoe-client enable [find where comment="Eng-Osamah"];
};

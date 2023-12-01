#----------- اصدار الميكروتيك V6
#:set ($InNames->("ether1"))  ({"speed"=2; "username"="USERNAME"; "password"="PASSWORE"; "ip"="192.168.10.1"});
#----------- المنفد بدل 
#---------- ether1
#----------- السرعة غير الرقم فقط
#---------- speed=2
#----------- اذاكان بردج غير 
#        USERNAME
#        PASSWORE
# مثال
#---------- "username"="A234342"; "password"="12345";
#----------- اذا كان دمح عادي امسح اسم المستخدم وكلمة السر واكتب الايبي والسرعة
# مثال
#:set ($InNames->("ether1"))  ({"speed"=2; "ip"="192.168.10.1"});

#  مثال على الدمج بردج
#:set ($InNames->("ether1"))  ({"speed"=2; "username"="A123"; "password"="123456"});
#:set ($InNames->("ether2"))  ({"speed"=4; "username"="B123"; "password"="123456"});
#  مثال على الدمج العادي
#:set ($InNames->("ether2"))  ({"speed"=4; "ip"="192.168.11.1"});
#:set ($InNames->("ether3"))  ({"speed"=8; "ip"="192.168.12.1"});
#  انسخ السطر وكرر العملية

#انسخ كامل مع الاقواس 
#انسخ كامل مع الاقواس 
#انسخ كامل مع الاقواس 
#انسخ كامل مع الاقواس 

{:local InNames [:toarray ""];
:local OutName ("ether13");
:set ($InNames->("ether1"))  ({"speed"=2; "username"="USERNAME"; "password"="PASSWORE"; "ip"="192.168.10.1"});
:set ($InNames->("ether2"))  ({"speed"=4; "username"="USERNAME"; "password"="PASSWORE"; "ip"="192.168.11.1"});
:set ($InNames->("ether3"))  ({"speed"=8; "username"="USERNAME"; "password"="PASSWORE"; "ip"="192.168.12.1"});
:set ($InNames->("ether4"))  ({"speed"=12; "username"="USERNAME"; "password"="PASSWORE"; "ip"="192.168.13.1"});
#---------------------------
:local OutNameB ("$OutName");
:local OutNameI ("$OutName");
:if ([:len [/interface bridge port find where interface=$OutName]]>0) do={:set $OutNameB [/interface bridge port get ([find where interface=$OutName]->0) bridge];:set $OutNameI $OutName;};
:if ([:len [/interface bridge find where name=$OutName]]>0) do={:set $OutNameI [/interface bridge port get ([find where bridge=$OutName]->0) interface];:set $OutNameB $OutName;};
:do {/interface list add comment="Eng-Osamah-AutoLoadBalancing" name=DAMGPPP;} on-error={};
:do {/interface list add comment="Eng-Osamah-AutoLoadBalancing" include=DAMGPPP name=DMGWAN;} on-error={};
:do {/interface list add comment="Eng-Osamah-AutoLoadBalancing" name=DMGLAN;} on-error={};
:do {/interface list member add interface=$OutNameB comment="Eng-Osamah-AutoLoadBalancing" list=DMGLAN;} on-error={};
:local ARR [:toarray ""];:local Total 0;:local Min 10000;:local Max 0;:local i 0;:local ALLPPP;:local ALLETH;
:foreach N,V in=$InNames do={
    :if ($N=$OutNameI||$N=$OutNameB) do={:set ($InNames->$N);} else={
        :set $i ($i+1);
        :if (([:len ($V->("username"))]>0)&&([:len ($V->("username"))]>0)) do={
            :if ((($V->("username"))!="USERNAME") && (($V->("password"))!="PASSWORE")) do={
                :do {/interface list member add interface=$N comment="Eng-Osamah-AutoLoadBalancing" list=DMGWAN;} on-error={ };
                :do {/interface pppoe-client add disabled=yes interface=$N comment="Eng-Osamah-AutoLoadBalancing" keepalive-timeout=30 name=("pppoe-out-$i") user=($V->("username"))  password=($V->("password"));} on-error={ };
                :do {/interface list member add interface=("pppoe-out-$i") comment="Eng-Osamah-AutoLoadBalancing" list=DAMGPPP;} on-error={};
                :set $ALLPPP ($ALLPPP,("pppoe-out-$i"));
                :set ($InNames->$N->("R")) ("pppoe-out-$i");
            } else={:set ($InNames->$N);:set $i ($i-1);};
        } else={
            :if (([:len ($V->("ip"))]>0)) do={
                :local ip [:toip ($V->("ip"))];
                :if ([:len [:tostr $ip]]=0) do={:error ("not correct ip".($V->("ip")));};
                :local wip $ip;
                :if ((($ip)&(0.0.0.255))>(0.0.0.250)) do={:set $wip ($wip-1);} else={:set $wip ($wip+1);};
                :foreach i in=$ALLETH do={:if ($i=$wip) do={:set $wip ($wip+1);};};
                :do {/interface list member add interface=$N comment="Eng-Osamah-AutoLoadBalancing" list=DMGWAN;} on-error={ };
                :do {/ip address add interface=$N comment="Eng-Osamah-AutoLoadBalancing" address=($wip."/24");} on-error={ };
                :set $ALLETH ($ALLETH,$ip);
                :set ($InNames->$N->("R")) $ip;
            } else={:set ($InNames->$N);:set $i ($i-1);};
        }
    }
}
:local ALLOUT ($ALLETH,$ALLPPP);:local LINES ([:len $ALLOUT]);:set $i 0;
:foreach N,V in=$InNames do={:local j ($V->("speed"));:if ($j=0) do={:error ("not correct speed");};:set $Total ($Total+$j);:if ($j<$Min) do={:set $Min $j;};:if ($j>$Max) do={:set $Max $j;};};
:if ($Total=0 || $Min=0 || $Max=0) do={:error "not correct number";} 
:local Con (($Total/$Min));:local ConN 0;
:do {/ip route add disabled=yes gateway=$ALLOUT comment="Eng-Osamah-AutoLoadBalancing";} on-error={};
:do {/ip firewall nat add action=masquerade disabled=yes chain=srcnat out-interface-list=DMGWAN comment="Eng-Osamah-AutoLoadBalancing";} on-error={};
:do {/ip firewall nat add action=masquerade disabled=yes chain=srcnat out-interface-list=("pppoe-out") comment="Eng-Osamah-AutoLoadBalancing";} on-error={};
:set $i 0;
:foreach N,V in=$InNames do={
:local j ($V->("speed"));:set $i ($i+1);:local n ($j/$Min);:if ($n=0) do={:set $n 1;};
:for k from=1 to=$n do={/ip firewall mangle add comment="Eng-Osamah-AutoLoadBalancing" disabled=yes action=mark-connection chain=prerouting connection-mark=no-mark dst-address-type=!local in-interface-list=DMGLAN new-connection-mark=("C_$i") passthrough=yes per-connection-classifier=("both-addresses-and-ports:$Con/$ConN");:set $ConN ($ConN+1);};
:if ($LINES=$i) do={/ip firewall mangle add comment="Eng-Osamah-AutoLoadBalancing" disabled=yes action=mark-connection chain=prerouting connection-mark=no-mark dst-address-type=!local in-interface-list=DMGLAN new-connection-mark=("C_$i") passthrough=yes;:set $ConN ($ConN+1);};
/ip firewall mangle add comment="Eng-Osamah-AutoLoadBalancing" disabled=yes action=mark-routing chain=prerouting connection-mark=("C_$i") in-interface-list=DMGLAN new-routing-mark=("R_$i") passthrough=no;
/ip route add comment="Eng-Osamah-AutoLoadBalancing" disabled=yes gateway=($V->("R")) routing-mark=("R_$i");
};
/ip route enable  [find where comment="Eng-Osamah-AutoLoadBalancing"];
/ip firewall nat enable [find where comment="Eng-Osamah-AutoLoadBalancing"];
/ip firewall mangle enable [find where comment="Eng-Osamah-AutoLoadBalancing"];
/interface pppoe-client enable [find where comment="Eng-Osamah-AutoLoadBalancing"];
/ip address enable [find where comment="Eng-Osamah-AutoLoadBalancing"];};

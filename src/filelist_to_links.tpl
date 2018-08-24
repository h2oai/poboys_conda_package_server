<h1>{{header}}</h1>

%if len(message) > 0:
<h2>Message</h2>
<div>{{message}}</div>

<h2>Available {{header}}</h2>
%end


%for f in filelist:
    <div>
        <a href="{{prefix}}{{parenturl}}/{{f}}" style="display: inline-block;" >{{f}}</a>
    %if allow_delete and f.endswith(".tar.bz2"):
        <form action="{{prefix}}/delete{{parenturl}}/{{f}}" method="post" style="display: inline-block;">
            <input type="submit" value="Delete" />
        </form>
    %end
    %if anaconda_release and f.endswith(".tar.bz2"):
        <form action="{{prefix}}/anaconda/release{{parenturl}}/{{f}}" method="post" style="display: inline-block;">
            <input type="submit" value="Anaconda Release" />
        </form>
    %end
    </div>
%end

function varargout = main(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @main_OpeningFcn, ...
                   'gui_OutputFcn',  @main_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT
% --- Executes just before main is made visible.
function main_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
guidata(hObject, handles);
function varargout = main_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;
function pushbutton2_Callback(hObject, eventdata, handles)

run fault
% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)

run greenfunc
% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)

run soil
% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)

run model
function location_Callback(hObject, eventdata, handles)
% --- Executes during object creation, after setting all properties.
function location_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)

global slip W L depth dip rake grid sample...
    Lx Ly Lz dx dy dz multilayer h E v ro location
ob_depth=0;%观测深度
r1=0;r2=sqrt((L/2+Lx/2)*(L/2+Lx/2)+(Ly/2+W*cos(dip/180*pi))*(Ly/2+W*cos(dip/180*pi)));%径向起始点和终点
nr=ceil(r2/grid+1);%径向点个数
zs1=0;zs2=W*sin(dip/180*pi)+depth;%竖向起始点和终点
nzs=ceil(zs2/grid+1);%竖向点个数
    for i=0:dz:Lz
        %写入edgrn文件
        if multilayer~=1
            fid=fopen('edgrn.inp','w+');
            fprintf(fid,'%s\n','# 观测点深度');
            fprintf(fid,'%s\n','# 径向点个数 起始点 终点');
            fprintf(fid,'%s\n','# 竖向点个数 起始点 终点');
            fprintf(fid,'%d\n',ob_depth); 
            ob_depth=ob_depth+dz;
            fprintf(fid,'%d %d %d\n',nr,r1,r2);
            fprintf(fid,'%d %d %d\n',nzs,zs1,zs2);
            fprintf(fid,'%s\n','# 波数积分采样率');
            fprintf(fid,'%d\n',sample); 
            fprintf(fid,'%s\n','# 输出文件位置和文件名');
            fprintf(fid,'%s %s %s %s\n',location,"'izmhs.ss'","'izmhs.ds'","'izmhs.cl'");
            fprintf(fid,'%s\n','# 土体层号');
            j=0;
            for k=1:multilayer
                j=j+h(k);
                if j<zs2
                    num=2*multilayer-1;
                else                
                    num=2*k-1;
                    break
                end
            end
            fprintf(fid,'%d\n',num); 
            fprintf(fid,'%s\n','#土层参数 深度m P波波速m/s S波波速m/s 密度kg/m^3');
            j=0;
            for k=1:multilayer
                G(k)=E(k)/2/(1+v(k));%地基剪切模量
                lmt(k)=E(k)*v(k)/(1+v(k))/(1-2*v(k));%拉梅常数中的lmt
                VP(k)=sqrt((lmt(k)+2*G(k))/ro(k));%计算地基中纵波波速
                VS(k)=sqrt(G(k)/ro(k));%计算地基中横波波速
                fprintf(fid,'%d  %d  %d  %d  %d\n',2*k-1,j,VP(k),VS(k),ro(k));
                j=j+h(k);
                if j<zs2             
                    fprintf(fid,'%d  %d  %d  %d  %d\n',2*k,j,VP(k),VS(k),ro(k));
                else
                    break
                end
            end
            fclose(fid);  
            ! edgrn-zidong
        end

        plane=[num2str(i),'mhs.disp'];%写入深度为i米的观测面的参数，建立inp文件
        fid=fopen('edcmp.inp','w+');
        fprintf(fid,'%s\n','# 观测面');
        fprintf(fid,'%d\n',2); 
        fprintf(fid,'%d %d %d\n',Lx/dx+1,L/2-Lx/2,L/2+Lx/2);
        fprintf(fid,'%d %d %d\n',Ly/dy+1,-1*Ly/2,Ly/2);
        fprintf(fid,'%s\n','# 输出文件名');
        fprintf(fid,'%s\n',"'./'");
        fprintf(fid,'%d %d %d %d\n',1,0,0,0');
        fprintf(fid,'%s %s %s %s\n',plane,"'izmhs.strn'","'izmhs.strss'","'izmhs.tilt'");
        fprintf(fid,'%s\n','# 断层点源数量');
        fprintf(fid,'%d\n',1); 
        fprintf(fid,'%s\n','# 震源参数 序号 位错量 左上角点坐标xyz 埋深 长 宽 倾角 滑动角');
        fprintf(fid,'%d %d %d %d %d %d %d %d %d %d\n',1,slip,0,0,depth,L,W,0,dip,rake); 
        fprintf(fid,'%s\n','#土层参数 成层为1 均匀为0，拉梅常数 lambda mu');
        if multilayer==1
            fprintf(fid,'%d\n',0);
            lmt=E(1)*v(1)/(1+v(1))/(1-2*v(1));%拉梅第一常数
            G=E(1)/2/(1+v(1));%拉梅第二常数，即剪切模量
            fprintf(fid,'%d %d %d\n',i,lmt,G); 
        else
            fprintf(fid,'%d\n',1); 
            fprintf(fid,'%s\n','# 格林函数文件的位置和文件名');
            fprintf(fid,'%s %s %s %s\n',location,"'izmhs.ss'","'izmhs.ds'","'izmhs.cl'");
        end
        fclose(fid); 
        fprintf('开始第%d次计算\n',i/dz+1)
        ! edcmp-zidong
        fprintf('第%d次计算完成\n',i/dz+1)
        %下一步为结果处理部分，对计算得到的*mhs.disp文件进行读取
        %x y z表示edcmp计算程序的整体坐标系
        %X Y Z表示abaqus模型的局部坐标系
        %二者之间的平移转换矩阵为[X Y Z]=[x y z]+[-L/2-Lx/2,+Ly/2,-Lz],旋转转换矩阵为[-1 1 -1]
        A=importdata(plane);%读取edcmp程序观测面的计算结果，第i米深度的土层表面变形
        B=A.data;%矩阵B存储了点的位移信息：五列分别为x, y坐标，ux,uy,uz位移量
        m=size(B,1);
        Z((1:m),1)=i;%深度z的坐标
        coor1=[B(:,1:2),Z];
        T1=[-L/2-Lx/2,+Ly/2,-Lz];
        COOR1=coor1+T1;
        COOR1(:,1)=COOR1(:,1)*-1;
        COOR1(:,3)=COOR1(:,3)*-1;
        %此时COOR1为观测区域各点在局部坐标系下的坐标
        COOR2=B(:,3:5);
        COOR2(:,1)=COOR2(:,1)*-1;
        COOR2(:,3)=COOR2(:,3)*-1;
        %此时COOR2为观测区域各点在局部坐标系下的位移值
        C=[COOR1,COOR2];    
        %此时C的六列分别为X，Y, Z坐标，UX,UY,UZ位移量
    %     X1=reshape(C(:,1),[Lx/dx+1,Ly/dy+1]);
    %     Y1=reshape(C(:,2),[Lx/dx+1,Ly/dy+1]);
    %     Z1=reshape(C(:,3),[Lx/dx+1,Ly/dy+1]);
    %     X1=X1';
    %     Y1=Y1';
    %     Z1=Z1';
        %将UX UY UZ矩阵进行重排列，为三维线性插值做准备
        UX=reshape(C(:,4),[Lx/dx+1,Ly/dy+1]);
        UY=reshape(C(:,5),[Lx/dx+1,Ly/dy+1]);
        UZ=reshape(C(:,6),[Lx/dx+1,Ly/dy+1]);
        UX=UX';
        UY=UY';
        UZ=UZ';
        Vx(:,:,Lz/dz+1-i/dz)=UX;%将每层的X方向位移存储至Vx矩阵，存储(Lz/dz+1)次
        Vy(:,:,Lz/dz+1-i/dz)=UY;
        Vz(:,:,Lz/dz+1-i/dz)=UZ; 

    end

coord_point=importdata('coord_point_suidao.rpt');%读取准备好的模型边界节点文件，获得节点编号和坐标
fid_inp=fopen('disp.inp','w');
fprintf(fid_inp,'%s\n','*Boundary');
   
x=fliplr(0:dx:Lx);
y=(0:dy:Ly)';
z=0:dz:Lz;

x1=coord_point(:,2);
y1=coord_point(:,3);
z1=coord_point(:,4);
%三维线性插值得模型边界上各点的位移值
disp_x=interp3(x,y,z,Vx,x1,y1,z1);
disp_y=interp3(x,y,z,Vy,x1,y1,z1);
disp_z=interp3(x,y,z,Vz,x1,y1,z1);
DISP=[coord_point,disp_x,disp_y,disp_z];
%将求得的各节点位移值写入disp.inp文件
for k=1:size(DISP)
   for j=1:3
       fprintf(fid_inp,'%s%d%s%d%s%d%s%f\r\n','Part-1-1.',DISP(k,1),', ',j ,', ',j ,', ',DISP(k,j+4));
   end
end
fclose(fid_inp); 
fprintf('disp.inp文件写入完成\n')

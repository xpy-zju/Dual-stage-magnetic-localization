function [s1,s2,p1,p2] = plot_Mag(T,r,h,Alpha,AlphaL)
    n = 20  ; 
    [X,Y,Z] = cylinder(r,n); 
    Z = Z*h;
    points = [reshape(X,[1,n*2+2]);reshape(Y,[1,n*2+2]);reshape(Z,[1,n*2+2]);ones(1,n*2+2)];
    points = T*points;
    diff = T(1:3,1:3)*[0,0,h]' + T(4,1:3);
    X = reshape(points(1,:),[2,n+1]);
    Y = reshape(points(2,:),[2,n+1]);
    Z = reshape(points(3,:),[2,n+1]);
    s1 = surf(X,Y,Z);
    s1.FaceAlpha = Alpha;
    s1.EdgeColor = 'none';
    s1.FaceColor = 'red';
    hold on
    s2 = surf(X-diff(1),Y-diff(2),Z-diff(3));
    s2.FaceAlpha = Alpha;
    s2.EdgeColor = 'none';
    s2.FaceColor = 'blue';
    
    p1 = fill3(X(2,:),Y(2,:),Z(2,:),'b');
    p1.FaceAlpha = Alpha;
    p1.EdgeAlpha = AlphaL;
    p1.FaceColor = 'red';
    
    p2 = fill3(X(1,:)-diff(1),Y(1,:)-diff(2),Z(1,:)-diff(3),'r');
    p2.FaceAlpha = Alpha;
    p2.EdgeAlpha = AlphaL;
    p2.FaceColor = 'blue';
    
end
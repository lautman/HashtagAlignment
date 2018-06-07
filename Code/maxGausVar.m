function [var] = maxGausVar (intensity,dis)
       
      for i = 1:1:30
       Gaus= -1*gausswin([4*dis +1],i);
       Gaus=(Gaus - min(Gaus)) / ( max(Gaus) - min(Gaus) );
       [acor,lag] = xcorr(intensity,Gaus);
       [val,~] = max(abs(acor));
       MaxAcor(i)=val
      end
      [val ind]=max(MaxAcor);
      var=ind;
end
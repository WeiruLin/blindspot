lvf_fillingin=load('LVF.fillingin');
lvf_fillingin=sortrows(lvf_fillingin, 4);


lvf_halfstim=load('LVF.halfstim');
lvf_halfstim=sortrows(lvf_halfstim, 4);

lvf_orthogonal=load('LVF.orthogonal');
lvf_orthogonal=sortrows(lvf_orthogonal, 4);

lvf_mean_fillingin=mean(lvf_fillingin(:,4));
lvf_mean_halfstim=mean(lvf_halfstim(:,4));
lvf_mean_orthogonal=mean(lvf_orthogonal(:,4));

bar([lvf_mean_fillingin lvf_mean_halfstim lvf_mean_orthogonal]);

for i=1:rvf_v2_num
    x=(rvf_v2_bs(i, 1)==rvf_v2_fillingin(:, 1));
    y=(rvf_v2_bs(i, 2)==rvf_v2_fillingin(:, 2));
    z=(rvf_v2_bs(i, 3)==rvf_v2_fillingin(:, 3));
    row=find(x.*y.*z==1);
    rvf_v2_bs_fillingin(i, :)=rvf_v2_fillingin(row, :);
end

for i=1:rvf_v2_num
    x=(rvf_v2_pbs(i, 1)==rvf_v2_fillingin(:, 1));
    y=(rvf_v2_pbs(i, 2)==rvf_v2_fillingin(:, 2));
    z=(rvf_v2_pbs(i, 3)==rvf_v2_fillingin(:, 3));
    row=find(x.*y.*z==1);
    rvf_v2_pbs_fillingin(i, :)=rvf_v2_fillingin(row, :);
end

for i=1:rvf_v2_num
    x=(rvf_v2_bs(i, 1)==rvf_v2_halfstim(:, 1));
    y=(rvf_v2_bs(i, 2)==rvf_v2_halfstim(:, 2));
    z=(rvf_v2_bs(i, 3)==rvf_v2_halfstim(:, 3));
    row=find(x.*y.*z==1);
    rvf_v2_bs_halfstim(i, :)=rvf_v2_halfstim(row, :);
end

for i=1:rvf_v2_num
    x=(rvf_v2_pbs(i, 1)==rvf_v2_halfstim(:, 1));
    y=(rvf_v2_pbs(i, 2)==rvf_v2_halfstim(:, 2));
    z=(rvf_v2_pbs(i, 3)==rvf_v2_halfstim(:, 3));
    row=find(x.*y.*z==1);
    rvf_v2_pbs_halfstim(i, :)=rvf_v2_halfstim(row, :);
end

for i=1:rvf_v2_num
    x=(rvf_v2_bs(i, 1)==rvf_v2_orthogonal(:, 1));
    y=(rvf_v2_bs(i, 2)==rvf_v2_orthogonal(:, 2));
    z=(rvf_v2_bs(i, 3)==rvf_v2_orthogonal(:, 3));
    row=find(x.*y.*z==1);
    rvf_v2_bs_orthogonal(i, :)=rvf_v2_orthogonal(row, :);
end

for i=1:rvf_v2_num
    x=(rvf_v2_pbs(i, 1)==rvf_v2_orthogonal(:, 1));
    y=(rvf_v2_pbs(i, 2)==rvf_v2_orthogonal(:, 2));
    z=(rvf_v2_pbs(i, 3)==rvf_v2_orthogonal(:, 3));
    row=find(x.*y.*z==1);
    rvf_v2_pbs_orthogonal(i, :)=rvf_v2_orthogonal(row, :);
end

rvf_v2_mean_bs_fillingin=mean(rvf_v2_bs_fillingin(:,4));
rvf_v2_mean_bs_halfstim=mean(rvf_v2_bs_halfstim(:,4));
rvf_v2_mean_bs_orthogonal=mean(rvf_v2_bs_orthogonal(:,4));

rvf_v2_mean_bs=[rvf_v2_mean_bs_fillingin, rvf_v2_mean_bs_halfstim, ...
    rvf_v2_mean_bs_orthogonal];

rvf_v2_mean_pbs_fillingin=mean(rvf_v2_pbs_fillingin(:,4));
rvf_v2_mean_pbs_halfstim=mean(rvf_v2_pbs_halfstim(:,4));
rvf_v2_mean_pbs_orthogonal=mean(rvf_v2_pbs_orthogonal(:,4));

rvf_v2_mean_pbs=[rvf_v2_mean_pbs_fillingin, rvf_v2_mean_pbs_halfstim, ...
    rvf_v2_mean_pbs_orthogonal];
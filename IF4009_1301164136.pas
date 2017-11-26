{program	: AplikasiListrik.pas
 deskripsi	: Untuk simulasi penginputan data pelanggan listrik dan simulasi tagihan listrik per bulan dalam bahasa Indonesia
 tanggal	: Desember 2016}

PROGRAM IF4009_1301164136;

USES crt, sysutils;

TYPE
	waktu = record
		bulan: word;
		tahun: word;
	end;
	tarif = record
		adm: real;
		kwh: real;
		denda: real;
		reduksi: real;
		total: real;
	end;
	pelanggan = record
		daya: integer;
        nama: string;
		alamat: string;
		pemakaian: real;
		kupon: integer;
		tagihan: tarif;
		periode: waktu;
	end;
	tabel = array of pelanggan;
	
CONST
	garis='================================================';
	
	adm1=11000;
	adm2=20000;
	kwh1=415;
	kwh2=605;
	kwh3=790;
	kwh4=795;
	kwh5=890;
	kwh6=1330;
	dendabulanan=10000;
	reduk=2000;

VAR {Global}
	tab: tabel;
	f: file of pelanggan;
	g: textfile;

procedure Boot();
{IS. -
 FS. Menampilkan splash screen}
begin
	clrscr;
	writeln(garis);
	writeln('=                                              =');
	writeln('=      SELAMAT DATANG DI APLIKASI LISTRIK      =');
	writeln('=                                              =');
	writeln('=              Wikan Kuncara Jati              =');
	writeln('=                   IF-40-09                   =');
	writeln('=                  1301164136                  =');
	writeln('=                                              =');
	writeln(garis);
	writeln('Tekan enter...');
	readln;
end;

function kategori(i:integer):string;
begin
	case i of
		1: kategori:='450VA';
		2: kategori:='900VA';
		3: kategori:='1300VA';
		4: kategori:='2200VA';
		5: kategori:='3500VA';
		6: kategori:='6600VA';
	end;
end;

procedure printToFile(A: pelanggan);
{IS. Terdefinisi data pembayaran pelanggan
 FS. Menyimpan data pembayaran ke dalam sebuah file .txt}
var
	s: string;
begin
	s:='tagihan.txt';
	assign(g,s);
	rewrite(g);
	
	writeln(g,garis);
	writeln(g,'Nama:               : ',A.nama);
	writeln(g,'Alamat:             : ',A.alamat);
	writeln(g,'Daya Listrik        : ',kategori(A.daya));
	writeln(g,'Periode:            : ',A.periode.bulan,'/',A.periode.tahun);
	writeln(g,garis);
	writeln(g,'Rincian Biaya');
	writeln(g,garis);
	writeln(g,'Biaya Administrasi  : Rp',A.tagihan.adm:0:2);
	writeln(g,'Biaya Pemakaian     : Rp',A.tagihan.kwh:0:2);
	writeln(g,'Biaya Denda         : Rp',A.tagihan.denda:0:2);
	writeln(g,'Reduksi Kupon Sampah: Rp',A.tagihan.reduksi:0:2);
	writeln(g,'');
	writeln(g,'TOTAL               : Rp',A.tagihan.total:0:2);
	
	close(g);
end;

procedure saveToFile(var A: tabel);
{IS. Terdefinisi data pelanggan dalam array
 FS. Mengosongkan file, menyimpan array data pelanggan dalam sebuah file .dat, dan menutup file-nya}
var
	i: integer;
	temp: pelanggan;
begin
	rewrite(f);
    for i:=0 to length(A)-1 do
    begin
        temp := A[i];
        write(f, temp);
    end;
    close(f);
end;

procedure readFromFile(var A: tabel);
{IS. -
 FS. Membuka file .dat yang sudah ada, atau membuat file .dat jika belum ada dan menyimpan datanya ke dalam array pelanggan}
var
	i: integer;
	temp: pelanggan;
begin
    if fileExists('data.dat') then
		assign(f,'data.dat')
    else
	begin
		fileCreate('data.dat');
		assign(f,'data.dat');
	end;
	
    reset(f);
    i:=0;
    while not eof(f) do begin
        read(f, temp);
        setLength(A,i+1);
        A[i]:= temp;
        i:=i+1;
	end;
end;

function search(nama: string; A: tabel):integer;
{IS. Input string yang akan dicari dari array yang akan dicari
 FS. Jika ketemu maka output nomor indeks data, jika tidak maka output -1}
var
	found: boolean;
	i: integer;
begin
	i:=0; found:=false;
		while (i <= length(A)-1) and (not found) do begin
			if nama = A[i].nama then
			begin
				search:=i;
				found:= true;
			end
			else
				i:= i + 1;
		end;
		if not found then
		begin
			search:=-1;
		end;
end;

function SelisihBulan(bulan,tahun: word):integer;
{IS. Terdefinisi bulan dan tahun yang ingin diselisihkan
 FS. Menghasilkan nilai selisih bulan dalam satuan waktu bulan}
var
	DD,MM,YY: word;
begin
	DeCodeDate (Date,YY,MM,DD);
	SelisihBulan:=(MM+(12*YY))-(bulan+(12*tahun));
end;

procedure hitungTagihan(var A:pelanggan);
{IS. Terdefinisi pemakaian listrik seorang pelanggan
 FS. Menampilkan biaya-biaya yang harus dibayarkan}
var
	telat: integer;
	opt: char;
begin
	telat:=SelisihBulan(A.periode.bulan, A.periode.tahun);
	
	case A.daya of
		1:	begin
			A.tagihan.adm:=adm1;
			A.tagihan.kwh:=kwh1*A.pemakaian;
			end;			
		2:	begin
			A.tagihan.adm:=adm2;
			A.tagihan.kwh:=kwh2*A.pemakaian;
			end;
		3:	begin
			A.tagihan.adm:=0;
			A.tagihan.kwh:=kwh3*A.pemakaian;
			end;
		4:	begin
			A.tagihan.adm:=0;
			A.tagihan.kwh:=kwh4*A.pemakaian;
			end;
		5:	begin
			A.tagihan.adm:=0;
			A.tagihan.kwh:=kwh5*A.pemakaian;
			end;
		6:	begin
			A.tagihan.adm:=0;
			A.tagihan.kwh:=kwh6*A.pemakaian;
			end;
	end;
			
	if telat>0 then
		A.tagihan.denda:=telat*dendabulanan
	else
		A.tagihan.denda:=0;
		
	if A.kupon>0 then
		A.tagihan.reduksi:= (-reduk)*A.kupon
	else
		A.tagihan.reduksi:= 0;
	
	A.tagihan.total := A.tagihan.adm + A.tagihan.kwh + A.tagihan.denda + A.tagihan.reduksi;
	
	writeln(garis);
	writeln('Rincian Biaya');
	writeln(garis);
	writeln('Biaya Administrasi  : Rp',A.tagihan.adm:0:2);
	writeln('Biaya Pemakaian     : Rp',A.tagihan.kwh:0:2);
	writeln('Biaya Denda         : Rp',A.tagihan.denda:0:2);
	writeln('Reduksi Kupon Sampah: Rp',A.tagihan.reduksi:0:2);
	writeln;
	writeln('TOTAL               : Rp',A.tagihan.total:0:2);
	
	repeat
		write('Apakah anda ingin mencetak struk tagihan ini? (y/n): '); readln(opt);
		if lowercase(opt) = 'y' then
			printToFile(A);
	until (lowercase(opt)='y') or (lowercase(opt)='n');
end;

procedure searchData(var A: tabel);
{IS. Terdefinisi data pelanggan dalam array dan kata kunci berupa yang akan dicari
 FS. Output data pelanggan dalam array}
var
	nama: string;
	i: integer;
begin	
	writeln(garis);
	write('Nama pelanggan yang dicari: '); readln(nama);
	writeln('Mencari data...');
	i:=search(nama,tab);
	writeln(garis);
	if i>=0 then
	begin
		writeln(nama,' ditemukan pada indeks ke-',i+1);
		writeln('menampilkan data...');
		writeln(garis);
        writeln('Nama             : ',A[i].nama);
        writeln('Alamat           : ',A[i].alamat);
        writeln('Daya Listrik     : ',kategori(A[i].daya));
	end
	else
		writeln('Nama tidak ditemukan...');
	readln;
end;
	
procedure sortName(var A: tabel);
{IS. Terdefinisi data pelanggan dalam array
 FS. Mengurutkan data pelanggan dalam array berdasarkan nama pelanggan}
var
    i,pass,ix: integer;
    temp: pelanggan;
	opt: char;
begin
	writeln(garis);
		writeln('Data akan diurutkan berdasarkan nama');
	writeln('[1]Dari A-Z');
	writeln('[2]Dari Z-A');
	write('Masukkan pilihan :');
	repeat
		readln(opt);
	until (opt='1') or (opt='2');
	for pass:=0 to length(A)-2 do begin
		ix:=pass;
			for i:=pass+1 to length(A)-1 do begin
				if (A[i].nama<A[ix].nama) and (opt='1') then
				ix:=i;
				if (A[i].nama>A[ix].nama) and (opt='2') then
				ix:=i;
			end;
        temp:=A[pass];
        A[pass]:=A[ix];
        A[ix]:=temp;
		end;
end;
	
procedure sortGol(var A: tabel);
{IS. Terdefinisi data pelanggan dalam array
 FS. Mengurutkan data pelanggan dalam array berdasarkan golongan listrik pelanggan}
var
    i,pass,ix: integer;
    temp: pelanggan;
	opt: char;
begin
	writeln(garis);
	writeln('Data akan diurutkan berdasarkan golongan');
    writeln('[1]Dari besar ke kecil');
	writeln('[2]Dari kecil ke besar');
	write('Masukkan pilihan: ');
    repeat
        readln(opt);
    until (opt='1') or (opt='2');
    for pass:=0 to length(A)-2 do begin
		ix:=pass;
			for i:=pass+1 to length(A)-1 do begin
				if (A[i].daya>A[ix].daya) and (opt='1') then
				ix:=i;
				if (A[i].daya<A[ix].daya) and (opt='2') then
				ix:=i;
			end;
        temp:=A[pass];
        A[pass]:=A[ix];
        A[ix]:=temp;
		end;
end;	
	
procedure sortDataOption(opsi: char);
{IS. Pilihan dari menu sort
 FS. Memanggil prosedur yang bersangkutan}
begin
	case opsi of
	'1': sortName(tab);
	'2': sortGol(tab);
	end;
end;	

procedure sortData(var A: tabel);
{IS. Terdefinisi data pelanggan dalam array
 FS. Mengurutkan data pelanggan dalam array}
var
    opsi: char;
begin
	writeln(garis);
	writeln('[1]Berdasarkan Nama');
	writeln('[2]Berdasarkan Golongan');
	write('Masukkan pilihan: ');
	readln(opsi);
	sortDataOption(opsi);
end;

procedure editData(var A: tabel);
{IS. Terdefinisi data pelanggan dalam array
 FS. Mengubah data pelanggan dalam array tersebut}
var
	p: char;
	opsi: integer;
	temp: pelanggan;
begin
	writeln(garis);
    writeln('Edit Data');
	repeat
		write('Data yang akan di Edit: '); readln(opsi);
	until opsi<=length(A);
    opsi:=opsi-1;
    repeat
        write('Nama             : '); readln(temp.nama);
		write('Alamat           : '); readln(temp.alamat);
		writeln('Daya Listrik');
		repeat
			writeln('     1. 450VA');
			writeln('     2. 900VA');
			writeln('     3. 1300VA');
			writeln('     4. 2200VA');
			writeln('     5. 3500VA');
			writeln('     6. 6600VA');
			writeln('Pilih golongan: ');
			readln(temp.daya);
		until (temp.daya=1) or (temp.daya=2) or (temp.daya=3) or (temp.daya=4) or (temp.daya=5) or (temp.daya=6);
			write('Apakah anda yakin dengan inputan anda? [y/n]'); readln(p);
	until (lowercase(p)='y');
        A[opsi]:=temp;
end;

procedure deleteData(var A: tabel);
{IS. Terdefinisi data pelanggan dalam array
 FS. Menghapus data pelanggan dalam array tersebut}
var
	i,n,opsi: integer;
	p: char;
begin
	n:=length(A);
    writeln('Delete Data');
    repeat
        write('Data yang akan dihapus: '); readln(opsi);
    until(opsi>=1) and (opsi<=length(A));

    repeat
        write('Yakin akan menghapus data no.',opsi,'? (y/n): ');
        readln(p);
    until (lowercase(p)='y') or (lowercase(p)='n');

    if (lowercase(p)='y') then
    begin
        i:=opsi-1;
        while(i<n-1) do begin
            if opsi-1<>n-1 then
                A[i]:=A[i+1];
            i:=i+1;
        end;
        setlength(A,n-1);
    end;
end;

procedure viewMenuOption(pil: char);
{IS. Pilihan dari menu view
 FS. Memanggil prosedur yang bersangkutan}
begin
	case pil of
		'1' : editData(tab);
		'2' : deleteData(tab);
		'3' : sortData(tab);
		'4' : searchData(tab);
	end;
end;

procedure viewBill(var A: tabel);
{IS. Terdefinisi data pelanggan dalam array
 FS. Menyimpan data pemakaian listrik seorang pelanggan}
var
	nama: string;
	i: integer;
	p: char;
begin
	clrscr;
	writeln(garis);
	writeln('DATA TAGIHAN LISTRIK');
	writeln(garis);
	
	write('Masukkan Nama       : '); readln(nama);
	i:=search(nama,tab);
	
	if i>=0 then
		begin
			writeln('Periode Pemakaian');
			repeat
				write('     Bulan (1-12)   : ');
				readln(A[i].periode.bulan);
			until (A[i].periode.bulan>0) and (A[i].periode.bulan<=12);
			repeat
				write('     Tahun          : ');
				readln(A[i].periode.tahun);
			until (A[i].periode.tahun>2015) and (A[i].periode.tahun<=2020);
			
			write('Daya yang terpakai (kWh)  : '); readln(A[i].pemakaian);
			
			repeat
				write('Punya kupon sampah? (y/n) : '); readln(p);
			until (lowercase(p)='y') or (lowercase(p)='n');
			if lowercase(p)='y' then
			begin
				write('Jumlah kupon yang dimiliki: '); readln(A[i].kupon);
			end;
			
			hitungTagihan(A[i]);
		end
	else
		writeln('Nama tidak ditemukan, kembali ke menu utama...');
	
	readln;
end;

procedure viewMenu(var A: tabel);
{IS. Terdefinisi data pelanggan dalam array
 FS. Menampilkan data pelanggan}
var
        i: integer;
        option: char;
begin
	repeat
        repeat
			clrscr;
            for i:=0 to length(A)-1 do begin
				if (i mod 4 = 0) then
				begin
					writeln(garis);
					writeln('DATA PELANGGAN');
					writeln(garis);
				end;
                writeln('No.              : ',i+1);
                writeln('Nama             : ',A[i].nama);
                writeln('Alamat           : ',A[i].alamat);
                writeln('Daya Listrik     : ',kategori(A[i].daya));
                writeln;
				if ((i+1) mod 4 = 0) then
				begin
					writeln(garis);
					writeln('Hal ',((i div 4)+1),'/',(((length(A)-1) div 4)+1));
					writeln(garis);
					writeln('Tekan [1] menyunting, [2] menghapus,');
					writeln('[3] mengurutkan, [4] mencari');
					writeln(garis);
					write('Masukkan pilihan: '); readln(option);
					viewMenuOption(option);
					clrscr;
				end
				else if (i = length(A)-1) then
				begin
					writeln(garis);
					writeln('Hal ',((i div 4)+1),'/',(((length(A)-1) div 4)+1));
					writeln(garis);
					writeln('Tekan [1] menyunting, [2] menghapus,');
					writeln('[3] mengurutkan, [4] mencari, [5] menu utama');
					writeln(garis);
					write('Masukkan pilihan: '); readln(option);
					viewMenuOption(option);
					clrscr;
				end;
            end;
        until (option='1') or (option='2') or (option='3') or (option='4') or (option='5');
	until (option='5')
end;

procedure inputMenu(var A: tabel);
{IS. -
 FS. Menyimpan data pelanggan pada array}
var
	N: integer;
begin
	clrscr;
	N:=length(A);
	setlength(A,N+1);
	writeln(garis);
	writeln('INPUT DATA');
	writeln(garis);
    write('Nama             : '); readln(A[N].nama);
    write('Alamat           : '); readln(A[N].alamat);
	writeln('Daya Listrik');
    repeat
		writeln('     1. 450VA');
		writeln('     2. 900VA');
		writeln('     3. 1300VA');
		writeln('     4. 2200VA');
		writeln('     5. 3500VA');
		writeln('     6. 6600VA');
		writeln('Pilih golongan: ');
		readln(A[N].daya);
	until (A[N].daya=1) or (A[N].daya=2) or (A[N].daya=3) or (A[N].daya=4) or (A[N].daya=5) or (A[N].daya=6);
    write('Data berhasil ditambahkan...'); readln;
end;

procedure optionMenu(opsi:integer);
{IS. Pilihan dari menu utama
 FS. Memanggil prosedur yang bersangkutan}
begin
	case opsi of
	        1: inputMenu(tab);
            2: viewMenu(tab);
			3: viewBill(tab);
	end;
end;

procedure mainMenu();
{IS. -
 FS. Menampilkan menu utama}
var
	opsi:integer;
begin
	repeat
	        clrscr;
	        writeln(garis);
			writeln('MENU UTAMA');
			writeln(garis);
	        writeln('1. Input Data          ');
            writeln('2. View Data           ');
            writeln('3. Lihat tagihan       ');
            writeln('4. Exit                ');
			writeln(garis);
            write('Masukkan pilihan: '); readln(opsi);

	until (opsi=1) or (opsi=2) or (opsi=3) or (opsi=4);
	if opsi<>4 then
		begin
			optionMenu(opsi);
			mainMenu;
		end
	else
		begin
			writeln('Yakin akan keluar dari program? (y/n)');
			readln;
		end;
end;


BEGIN
	readFromFile(tab);
	clrscr;
	Boot;
	mainMenu;
	saveToFile(tab);
END.
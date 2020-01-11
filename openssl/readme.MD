  Note: in order to run ssl program, you must have libeay32.dll and ssleay32.dll installed where the
        application can find them  (either in the Windows System32 folder, or in the same folder as the
        application itself.  These files can be downloaded from:  http://indy.fulgan.com/SSL/

        The server also requires that the certificate files (sample.crt, sample.key, and sampleRoot.pem)
        be available in the same folder as the excutable.
		
before run openssl, you must run 
set OPENSSL_CONF=[path-to-OpenSSL-install-dir]\bin\openssl.cfg		

OpenSSL 1.0.2u
1.首先要生成服务器端的私钥(key文件):
openssl genrsa -des3 -out server.key 1024
运行时会提示输入密码,此密码用于加密key文件(参数des3便是指加密算法,当然也可以选用其他你认为安全的算法.),以后每当需读取此文件(通过openssl提供的命令或API)都需输入口令.如果觉得不方便,也可以去除这个口令,但一定要采取其他的保护措施!
去除key文件口令的命令:
openssl rsa -in server.key -out server.key

2.openssl req -new -key server.key -out server.csr
生成Certificate Signing Request（CSR）,生成的csr文件交给CA签名后形成服务端自己的证书.屏幕上将有提示,依照其指示一步一步输入要求的个人信息即可.

3.对客户端也作同样的命令生成key及csr文件:
openssl genrsa -des3 -out client.key 1024
openssl req -new -key client.key -out client.csr

4.CSR文件必须有CA的签名才可形成证书.可将此文件发送到verisign等地方由它验证,要交一大笔钱,何不自己做CA呢.
openssl req -new -x509 -keyout ca.key -out ca.crt

5.用生成的CA的证书为刚才生成的server.csr,client.csr文件签名:
Openssl ca -in server.csr -out server.crt -cert ca.crt -keyfile ca.key
Openssl ca -in client.csr -out client.crt -cert ca.crt -keyfile ca.key

现在我们所需的全部文件便生成了.

另：
client使用的文件有：ca.crt,client.crt,client.key
server使用的文件有：ca.crt,server.crt,server.key
.crt文件和.key可以合到一个文件里面，本人把2个文件合成了一个.pem文件（直接拷贝过去就行了）

openssl x509 -in server.crt -out server.pem -outform PE

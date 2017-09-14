ME=`basename "$0"`
if [ "${ME}" = "install-hlfv1-unstable.sh" ]; then
  echo "Please re-run as >   cat install-hlfv1-unstable.sh | bash"
  exit 1
fi
(cat > composer.sh; chmod +x composer.sh; exec bash composer.sh)
#!/bin/bash
set -e

# Docker stop function
function stop()
{
P1=$(docker ps -q)
if [ "${P1}" != "" ]; then
  echo "Killing all running containers"  &2> /dev/null
  docker kill ${P1}
fi

P2=$(docker ps -aq)
if [ "${P2}" != "" ]; then
  echo "Removing all containers"  &2> /dev/null
  docker rm ${P2} -f
fi
}

if [ "$1" == "stop" ]; then
 echo "Stopping all Docker containers" >&2
 stop
 exit 0
fi

# Get the current directory.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the full path to this script.
SOURCE="${DIR}/composer.sh"

# Create a work directory for extracting files into.
WORKDIR="$(pwd)/composer-data-unstable"
rm -rf "${WORKDIR}" && mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# Find the PAYLOAD: marker in this script.
PAYLOAD_LINE=$(grep -a -n '^PAYLOAD:$' "${SOURCE}" | cut -d ':' -f 1)
echo PAYLOAD_LINE=${PAYLOAD_LINE}

# Find and extract the payload in this script.
PAYLOAD_START=$((PAYLOAD_LINE + 1))
echo PAYLOAD_START=${PAYLOAD_START}
tail -n +${PAYLOAD_START} "${SOURCE}" | tar -xzf -

# stop all the docker containers
stop



# run the fabric-dev-scripts to get a running fabric
./fabric-dev-servers/downloadFabric.sh
./fabric-dev-servers/startFabric.sh
./fabric-dev-servers/createComposerProfile.sh

# pull and tage the correct image for the installer
docker pull hyperledger/composer-playground:unstable
docker tag hyperledger/composer-playground:unstable hyperledger/composer-playground:latest


# Start all composer
docker-compose -p composer -f docker-compose-playground.yml up -d
# copy over pre-imported admin credentials
cd fabric-dev-servers/fabric-scripts/hlfv1/composer/creds
docker exec composer mkdir /home/composer/.composer-credentials
tar -cv * | docker exec -i composer tar x -C /home/composer/.composer-credentials

# Wait for playground to start
sleep 5

# Kill and remove any running Docker containers.
##docker-compose -p composer kill
##docker-compose -p composer down --remove-orphans

# Kill any other Docker containers.
##docker ps -aq | xargs docker rm -f

# Open the playground in a web browser.
case "$(uname)" in
"Darwin") open http://localhost:8080
          ;;
"Linux")  if [ -n "$BROWSER" ] ; then
	       	        $BROWSER http://localhost:8080
	        elif    which xdg-open > /dev/null ; then
	                xdg-open http://localhost:8080
          elif  	which gnome-open > /dev/null ; then
	                gnome-open http://localhost:8080
          #elif other types blah blah
	        else
    	            echo "Could not detect web browser to use - please launch Composer Playground URL using your chosen browser ie: <browser executable name> http://localhost:8080 or set your BROWSER variable to the browser launcher in your PATH"
	        fi
          ;;
*)        echo "Playground not launched - this OS is currently not supported "
          ;;
esac

echo
echo "--------------------------------------------------------------------------------------"
echo "Hyperledger Fabric and Hyperledger Composer installed, and Composer Playground launched"
echo "Please use 'composer.sh' to re-start, and 'composer.sh stop' to shutdown all the Fabric and Composer docker images"

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
� �@�Y �=�r�Hv��d3A�IJ��&��;ckl� 	�����*Z"%^$Y���&�$!�hR��[�����7�y�w���^ċdI�̘�A"�O�έ�U���Pp��-���0�c��~[t? ��$�?��)D���H��ј$	b�����~�{j!8�M �&�j�|�e���E��ac<?�8�]MA�6���M>�o�5��F��S�Pk�)k�;�ԑ�@fh�|��j���  �m	[�6��!����h#�"�
��L�Cꠘ����� ��Ox���o������6��
mHPfc0,:>��"d�j[3���ab]��ͫ�P��ٴb�zTɤU#��\�v�.0�T�]ܹ��g>̦�61�b�:4q]���溩�a�ԔE�W���Z�ҦUvG���2�Aa�T�Z늋[����M�j�6�9:�y�,�JVQ����]���C�9"�"���5�?�>-��i�fG��<�At��lǅ�0�)�3łQ(.[�և5,ZP�mu�iZ��l����"\e�3o�M���+0�	���K�Ddȟ3�ϟ�9��v�=���>:Ȳ���c�L�3G���}��K���#��;�S(c"�Gׯ�F���6[�Ĩ��3$��F���Y�4c<\�s���v*���'���6���G��|�/��O"_���d|��ߌ��q�p�p�j�j޵�����/��l��F ,J�\�K����_<�.TӌPZM�� �?}��S5��I��*)Wv?T�ʩ�[����<��{���S胎!�0�|i
�W3��>]��*��z��X���3��l�ๅ�{i���Is��İ��������N���^g�k�CB�"�`�-�>�Az����,`c@g�s�i@�d��E:�Г0�vZ6�8&ݎy�vL�m�5�t+2y�����G ��NC��]����"�X�����54���X���>��Dy��MlN4��n�tMA��ږ��4Q �@�$�UG[}~��a/k:VZJ�Gu��u�N�E;�ޛ�2�X���ߕ�Cw���<�MW�T�Z���G�@���gq �rq����,D�z;��@)�)L���4и��GbP����Gd�'��'�:�F��>���d|>X���u=����\�����I�DAZ��U����=��u�`'��nB�4]�P��ڸ�H!�c����8��e���M��ŝ��U�B�c���MN���ԛ<����y��%iU��&�i�҆����� |��Æ��@��OF��k���d�p������t���oҬ�� �i�:�Y�����d��!B1���������n�E�h��:��{L������;���68'"3˪S��Mޣ*� ؛� l�}6!c�롇g�Ob�?�ݥO�;V�Gr%G�Y%�w��}�I&���+��PG�B�B:Rl�kjJ`�ـϹ���9���M6�YG ��9O�79�P� �A��#��'�qzE:�Q�M>e8���t�L�^P3l�z5B�j�Gt����
�k]h�W�,�p*6���0��SF���
�?��E�������?_6̐��Z�SK�_���i��翫�OJ��a\��=[`g4��ӧ]=ꎙX�9���LXs�4�4)�5����>�Ηw>A�p��|�C%U�Vw~&�	y��gϳ+{;�gO�Ɛ�h����$^nVN��Ǚr%P|q1�͞�;� 48����I��6m��"�4rLV��B�8�[h>MB�n�=�|D:Kw*��[����j��98����ڬ��Q��Bd�Tk��&j�Qw�/4�γ?���/���<����۷��̆w�����-	s.�vu�+��k����߇_1���.��%���	oZ	���!O�y�e!~�-
?�E��c�f���l4��ya|w�����B|�����ߗ3�д�s�L�#�0���#����_��'���=1:m�dAtյ0�㄰�Aϲ��Νa��O�Kwoc���?������\,_�ù�z������n��w	
^v�#�#S�����%0��7Cw�� {pӲ2Ml�S3l�h��
rt@]j�M�u����1'�S�;?;���?/>%
~�1![i:6{��h_wIO���o٨h��=k�s"�����O�_�U��V,ԧJ��X��3�̍�ii��i�X�:����l��Y�\�_�#�ۄ{��bO!��Ʉ~k�E)XE`�2A<�Ιj��3�;%N�p�4�Ac�r����.A���\�>��D�����w���B>R��B��x!"6l�����Q)�큫ׂ�0����8��u�f  ���_���V�ѽM�������TkU��M��.A��?*Ŧ�?���%���V��Xƶ�hڠ�wB�C?�'�����Q���J7����Z���)Y����*������n�lwf�O���l6 ��N��s@F����~p��.t�Q��@H�s+ю0I�O= FC���>wC����?��A�x�Y=a����4�)Rf�%�r/ـQ���mb�v3�x �L!^Ύ�u$�%�L�4���5bFZ���@3�eL�>�!cV6��
c	0&�:�=����A!3X�6fyҔy	Rƒ��A�G�����uui�c�	-b
��q�ꟕ̻��^�
���#~�pc�?�p�������xXZ���n��#%檧�}������
����O4*��?W��}�}����������������??��"5A��pb����(%`�V���D"V�%�R8�$")&%j���@)M$�Z|+�mE���5����i��ƿr'w:�F��lp�pE��ƣo�r\
6m�io���?qC6*�������W�D���o���y��,����/���6���$Cv?��91��մ6��� ��_0�SF4�`�+�����Y�?�ʻp{�g�ڸ���k������sLޤ�%�?|}���Y��U�����J��J����0�(�I���u�Р���'O��3�,巯xKk�s�<���}�"��5�c���ķ"�V}+��T�RR8�hN�-
JD(n�a�&�!L@I��I�O�WQ�uj�p��\�R�r5�ͧ�j���3
�|*w�J�J�!��I��/�E��8.�諡d����5�i�^�q���g��s!Cp{�ef�P�[9Y<�$����q�"s)����1!UM���ZNo�"�x��Ȟ�G�3��>&ϴd���iX�<o]��W3�D��2㜽i6ko��Y%z^�i�8�j&\l�3��31{�M�X�*��y>\�慃j>|B��Y�0,{g��'k���K�N�ǥR.�{}|t�����ѥ���R8k����ҎvN���B����P|g��N>s�?=���7���e�^H
C��NJ'e�De2F��Q.k+�}�]�֪�32��B.���������R)�s/�+y9�s��.�%1׺�T�x�/��N�NΣv,M��\}��5�['�q�|T?�{�^�M��g�N/�U���VA=,�ΤL?���W����,�� �UӽL2�+�5�m�����r!)׷2�,R���Z�Ԟ�O��3�ē�d�a��[����N�H@�B*+h���]��NA����
�d�!2G�|)%Y{��;#�i|�UO��/ѓD�i�����QT1N�zǉnJ5�Jt/����}gq�3�^!w*�7ǅ�C(h����w��QY�yg0���3Ā�P0��>6���z 3������/�nnH�D1&����������o��_)|�������>�{�kX��/��G���DD1���[	��I���11`/s�Js�|n��dy��N��>T���|o?���PBk�b����X��oP1w��]=�F�ey�d��&q�R�\6�)�tT,w
G��,L�_\K픎_�P�1'����r���(zt��i�T��8�ة�Q*r(}���ӻU�Q��ą�cη|���g����/]��ѵ�_|6���>�����a�ó��:��J`��%��q�m�2��]��#%�����\Rҥ����ɦ�`5��pq�pB��^7:�y���Y��� �)��q���DcwĽ��֥m�mC>���ֻ��Q�ô���7��=�ܳ�ہO��~��4���5�}x�_	["�����Qi��q5��p�o���|�@��� �u�i�ʈ���(��������6����5dn�Q�[�G���F ���Fu��X��Ө.hh��@�mh��~�E-����}vi�?��d�8��5� ���~�f� i܆����X�}�M)�R�*V���EPC:�$�jtd#0�`��zú2�1�]l���y�s��<�F�={�P���y��N�>4�>�#���8Z��2��d�k�{u]�xͦ�p5�B42����>vL��k���U���EC�{�c,�)UD���+�.�6�  M�i�����65d�bFe}ڶ��.T��1���ۓ)��y}t4����&�~�����4,/�+]����3l�������o��P�V���ф��b�󘚊���	N��*��%�ß{鮎6Ix{b�u~0�o.'�B"^n���@�'sۅ�CX7q�u���'M/I͡DD�k�%0�ա��Ez?�`�=�m�W��1)����}���91��P�W����;:�M��k�M�}0dK�"�"kgf�jМS~�p�e(��_�k�{�{ѓ
D����&�T	�4��a��EèY���2ƃ��K��q���Z���7�wk	T�c�q�v��!Ư?�K�K7S�!���9���ҽ�M���׆�.��
����鋾CW��JU�m:��ҧ��|�ƛ�	,b"پnd�]eH'�&�n;�C'�(Ew,"EDW��&���=O����i��0Q��vG��rM�e�N�V!�C����|z��
�u��H��@�S��q�]�m7c�+�tڷA�/��n�,��`@>��2c���&NG�-�P��9�Np(�� *
}f��CUe��2��y���N-ВM����6�A,�d?b�����Q�?�=�������ߕ �"��޵�:�������"5��`�P�t��T���I.SR۱�87��y��rb'q�<n��I�X �h����;$f�����A,X �X���#�㾫rk�9��u�}�������K�G������_~{�����I�犁���/��?���o>�������8�=Y �q�����u�#�~ܺ�.&T����T(�	��!9BEk1C�HS�1�")���cd�#H���8A�m)#��I4��گ�×�o��ԏ����?����������~C��~�����+�����}�6���~������C�kB)����/��!���-��oA�C Z� �b��E��t3׍F�ǆ���R�M��O�N�����K��%@W!��W��*ć�jL�.�
�QU\K`F6k.�u��"�3�J����%M��\�H�א�g�Y�{�)a_�i�Vi�"
E����9f����1�-��+�f���R�����0�m����	ž�0a�Sn�X�o�3�J�^��f�<�1C(�f��7���%rw�kT#��Su�����1�<M/���9�T��a����~�/�l�/�cM��N�҅j1u�o"�e"����ss�$�e��Hv�l[H`&�Y��t!�2�����@��1���G��I�I�?h�5af��\6i =[�c9+�9�S�$%C;��\'E�T�ϥ��H�fw�f�6Zd��~�;>ob٢Ue��;�Ť�j���%�#�<��屚)S���8��[_�f��8��i�2II�j�l��0J��MJ�͍��+"��B��������<��+��.�K��K��K��K䮸K䮰K䮨K䮠K䮘K䮐K䮈Kd���`�E�,�h"��IR���QJ,P;Ǟ��f5/Ƙ�������Ŷ�!�E��(p.T��|� �sՃ��B�~kՃ �s;�5SV�=ܼ�5S�S?��j��2OM�X1IOCs��7�l�P#��Xn��,��b�ї�2�B-M���Vy*�(K�F���X�6����Im�@]�~W��D�D#�}�caLBbe.;[�r���S9��-M��y�u���'C�f�XG�\"F)� LvH3�3e�L��NL]�!#��~��k�=c�l�O(\2wZQ�r����򈌵Y��o��Y�p�p�wa�.~};�G�>޲�}��Go��[����V7��_½7v���ϐ���-�8��[���HS[��'�w��8r����ɇ:�kP���^<�Eo܁��՗7o^�:pQ��~ z��A�߾��>r~��G���0�����?�ރ�q�(�,-Q&K+���YN�U&�TY.R�Qr����%�E��K�\�'6��e&l��r&	XJ.�6V�`)OWr!������EW��:��2�M	\��+�s@��-�(U��N�Q<�RØ �Y�F)U`�x"�Rq*}̎�J�W@bT>\��ʱ��0�YO�,�PO�-���JK'Mc��z�]]��tG������HM�s���BղTw%�f-��t���f��`D�*�!-�l��2qFjrˁ��hG����q�r�RrtnI����'J�n����%}��)�N6E�G��ZS�|-���ny0�����"�~-gY�l�}�/�-�2B:B3��1���q���nXS��a����a��Z	�,�H��=����d�80����\��Q�/
�4�ᢙ�ޙv��-�?~���,0���3�rbIW\�d��~D<�b�5V�B[_d{�"��Ymd=��g��̬������m��ew��=��tϲ��fU���S��L��=���j"o�:����zR��J�-�%%�A��U�P+�e�φ��Q��Y4b���:/�yzU�>���T�~��
��C�+�@����نr\�i��f�/����Ts�u
�0�I�泎֞G���SkO'�:����J'�L[��dUX,�]Z����Z4�$%���Ų<�ҥ�,�0�6o�����Ţh1L���d*���S*�E�vk�0����4�c�/��hzYxv#����䉬�b�H��lPkjd*�1&#w���e��Mv��dd&iG�����!�=��&T&�m�`\e����K��dm�\eR漫P���j�RJC�r�u�V�sH�<ժ.6�X��u�]%��F��wny,�qI�c�z%#�g)�\U�ɐ��Ng*]v'@��V� �F١P"�L]<3���Ҕ���B'=CS��;A�RXH���S(�ͨ�(�w�i�МOqR�T�H�j�y����F�
>*[;LF-�c��ul*���Ps���ʆ���h���R��r�e��٥��]���oY6�#�]�n����"<���eB+��څ<�����-ZTtc��_�Gn�G���,8�U��Tc%� ��>�F^����0���ԥx/���������ϟ�<�BށyD�QR������ʳç����"i�l�����kz���+�7O#R�B��ZgdU� �qD�7�'���q��!9J��t������u/;�<p��剢� ����S:��u�^�^f�y����n���������0]���B[��!���o����6��'�~0�u�zd�v[�~'אn��;�0�JP�^��`����[�t&ê$=8�&�@1��ؑwR{G���}��rF�������>G�&����W����]= �;�9	~�amT���!�G����y�tu���}f]/���u��+Z�Zu��^���9�щ��z�|.�vL���������"�	:Y�G�	j� �G�~����( �h#��f��D��Z7 D� FW��BE_�oL���v����4Zcp�X�x�,Υ�`�7�zw4���P�t v9�����=_ͩ�� ���|�V�ت���ć��I�I��,�QСwA���9��
Zt��?_} k���������*Ù:��^�5�>蜯6��Dj���Y�A����W���_��'�N\l+Mv�dt��9��u��5��*��:	�]BG^�WĀ��Mt����X�Nl�Z&��C/:��VB ؆��:l�cI;	GV�'0\Y-j%�ȗ[/$�̀\1�ces�7�ןzP���f���	�v�!a?�Z[�o�ŦB�.�Y������Hס����:�n��CG�[� :l*DO��a�7�rMg��[�܇>��Ih���X��F��Q`[����$%�I��4�\vu�J]����EP�͖�Z��P��b�	�l} �u�dM"[W���6���	rO�;��y�6��� @�+�K%��D�Ꙥj�e��~�%CL����K6��i�nd�����+Nx�h��v�b�c��� �<�б�~��
"�G.j�P)�ea=���� ���R�������e 
�9� \�U導5�"̓�]֏�Hsu0�j��v�L�P ~��{(ܤ�S�B����Mk���n�2Úd{�����6A.��~d�xk��^���fK^uqձ�+�4a��4��߻<���Ŗ�/�A�}l|��۰�-��V}5Z�;-B$�E����[�d��v��|x�]M��SgFN���Zf&�>PV�5U�t���H�P>fu\�뾊�9�;x� �?�Q�#c�6q���8y���9'1,F�$��r�c�]���v��$����l(�D �n1����+��0Ts4�;rc�R~��qC���~T��S��Q�b��];����^s��u�s���7W�q��2Bl��$C�p���V2�'�'H@m�VɎ������N�d�mxV��4S��gq�D�x�*F�Y�C�;
��b�+�߲�UŎ�"]V
|<K�k4�ڵ���8�}:V�h蔫߬� d�"�&!IM2#�)!�MQ�VKi�r��K�Y����n�c�G���3�o2��|���+v��̉�cY����V����o����)*�r�Q�Xo��:���fU�1�I�R����Q,"K2N(�&�$I��pL�`Q*����BHH!k&�1%Qp��kb�O�v���sl�ȟ�٘Yv�@�M�S��{疄�\w4�8����{r���ʸk_�����Wp���m��rE���\�+ҙ�L.��*\晬4�����%���,[�J�g���s�K|I��T�}���Ⱥ��ܓ�.�]2�8�Jy�}�;�*7�t�Յ�>vϺ�
��{kGv&��t46��������vT�;mBZ�^�u�uT�`t�e���;�&�m2u�k-����0Q�:����Y��> �M��\L�[Q>/��x��"O���Y�����S4����UN�'X�)'׳V�3.��s|V|6��E�=kt&M��t��VOu?}��3�"/==��u��لGK�}cs�S�h*W�l�O�e9��+�
�螹lt濴������ۙ��v�yZLm���,�E�ؤU�$�"g�di�f��,B���%��r<�2Θ���	r#���h��2���ӣ��g����gmIӕX__$o���=":Y�����54<�Ew�n��X�[����+��]V��P��Vw�y�� �ȥ�����w����wǊ�[�q�2g�b�jb3p(�pTtz}������]/���,�K��"��/�Hw\�m��ƍ�?d���a���^��o��۬������Gz%�����o���{����-�6aCii��O��/�U���m�2>��}�}����O�=_ٴ/���_���������^��������@s�,}��J���_�o/i_��"�$k�V�(֎Deܒa����Rd��D�BE�h;�
��P3�*MLV�0!����E�_��*��C�m���%���0�7�i��k��P�#��NS��qEl��)�a�|��B�����'��?�*��T��5�A�ͥ�3rX)D��H��ȟV�e����R7BҲ>o�㧓R�ޛt*�IWK�+!,��j�:�wǨ�^��'K;���*��������/�ml�}��v�}��m��q�p����*��q�:��}�}�����=��|:�������u�GF"���t�� ��{
��� �����?�>�9��{I����Wq�pJ��t����򟤶�?u���H����~?;�D���%�/��	jK�����}�C��C��C�Οh��+a��;���^�+`�����k�Nݶ�����-����pA�����xEE��G�X��N*U���S�J%��d��֚��e���k�Z�?u7��_j���Z�P�S���'�����߼���������{s�u�U�k�T�pr�~���d�3Ѕ��i_W?�����>��m�û���O�c��y�<��*!��c{���Odi�=$v��j�u��z��Λ�f&��>���4Ӱbo�UGJW�*��^�ڍ��̋V�8Z�6?����/�Hͽ��>ok�ȏ�}*�~�e29j�{�`�[o�F����>��89w'��l�nɿ��ϻEs�,��ē#}��8vE���лF��b6�I�u��*�U�P�wY�~�+�?�>m�N��NS�Жs����j�n�A-���+C��ӂ(X � �����j�������H�*����?�p�w)��'���'������p�e��/�#��
P�m�W�~o���)��2P+��MP�"�P���uxs�߾������>��1����k������ؿq�������s]�R���hx�ſ/둷���~�I��<�����l ��h����`�Z�Q-�F�D�Vݔ�׌��ɮ*�Q��'��m{D���D��)X�f@�.gOe=�׺>�u>���� Q��\{.��h�j���������m�[�80�9��1�.pD#8�>.:K߄Rn&�>av�AFSQQ�����'��g�I
�\1��5G��T�ĳKq�P����_�����{��0�e��o��}���� P�m�W�'^����_
���ә�1��¦JcS��|��P���I��� `���	�f����"8�GC��qԁ���C�_~e�Vt]mq����l5ɒ�=�
y�A���������/��&�N�͑̏�<?)��5�,�LLd2ﺻ���7��&��7��g;F��H�%�����9L�~ڌ�H�6���Mې��^�����ա���~]�JQ��?�ա��?�����{����U�_u����ï���)�Mn7���,��f4�r�����`�p�E@Ya�n���%�<�~3f<��.5:�G�92˭8œK��Da�Z��*ڳCöF�γ�?2e�Ȧ����E=��8�������#������u������ �_���_����j�ЀU���a�����+o�?��迈���ߏȽ"�^xX���I��X>M�����J��~z��omrQ[�9 yz�'� @��g�p���2\��RE�� �y og	9p4����B+��D��n�����ur���,,K(b�����6��i�����K;�s�E���g�7�E�9��}7�^��5������3 L�%�p�vB$����D��;���nFQ?4��P�|+��N(k$RY������e�=o ��\bk#�ܱ�?�Ը���o�?i �u�Uy�������)�1�hm!�'3I�n���m�C2��.��k�Vҳ�"A��:���h��Gl�k��K��mg|���0��#A���Ͽ�Lx�e\�������P0�Q���8���������L�ڢ,�������_��?����������?a��_J���4�����,�L�)��d�z��y4Mr!��4�?���8>e��dḄ�;?u�������)�r�����e��5Y�]G��ǇC^<IFN΍�,hC'�
_�����H�-� z�Q=l�챑�͚zi��w���s����4�;�Jp�=8�u����h'r�۲w=�X�`������#���O)�|��F<T�,�2�������/���������P�{�u�u�?������WJ�����A;�&(��4�����+o�_����}��8�6C�q�6圌�8��+�n�;(*���x�6�-�������c���~_[��?�~����ވ�w�ys�[9��I01ey�l}�t��1�'�hA�ii��vGho��ѐY����x��M�8�t�e�4�X�b�L���K�g%ʵ�m]�'��˕��ޯ׶I���;�;0�*p�n�]��z���0P�^o��-Z���&=�p?��숪)��f҈(G[ߞ�$�5���`$�
���ɇ�Q�6#5�(�N�F�<MZ��z���s���Po�=4>�$���3�k=�]��.j�����?8߽����k�:�?���Z����P�?���	��+0���0�������y�o����%����������P:�?}	.@]P���A�/AB�_ ��!�����?��FA���Ͽ�����y����������ԁ�q���	��2P�?���B� ��������P1�C8D� ���������KA��!*�?���O=8��?JA���!�FY����$�?������W�p�j���;��?JB�l�T�������Sw���%�F�k!������J�?@��?@���A�U�� �B@����_-�����^��e������J�?@��?@�C���������/�#��
P�m�W�~o������RP+�����Q���������?����K��B-��@�a���@��2<g�dB�_�������O�z/���N��a1�!C�34`Xeg,��g�ĉ�B4;�Ѐ ���X��|��<�#I��_�Y���u��Ơ�����ux����ɓ[���/'�O����w�L3BQ5�v-��\��i���C��ơ��V��%�A1��~�xC����(f�cR�Y-OdŐ\����B���Pg��
)g�ƕ8磍�$�����M�9��R�F�u(��D��vwO���f����?�C����
��������C-��*C�����q)�~1� ���P�U�_Y��B�N�}��[���"�Fw��EZ�˿la���̧��{���p����(�d�a��\�ƫ�d��s1��F�	;��mә7P��$=)���ե~���f������fџ˔��{Q�������������`�;����a�����������?����@V�Z�ˇ���������=��)����I��8w������
�Y������j������N\�U��_>ց�{2����얩4�q�mi�jOR?B��L%;��v6�vĔn4��AF��`iz�Ş�Έ�0�q7�S� =�32]Ir�^ۍ��W����t�����鴄\.�-�������,��=�݌�~h(ǡ �,V�w�P(֑ʲ�1�V/3HG��^�MQm3'��r�>?�?�D�Nս�<���{rg���5�����XP�)�m�����4Z���)��I���T#<l�es�I)fk�����I�Ov�p����w�x�ep����ϸ������O\�׿ԡ�������]
>�����#^�E�����D1��ԁ�q������e�����L���,������G�8�_x��3lQ�����q\��f3��t��].��_��ђx��!⯛�I�<;n��G�z�+��~�J�d�!=��f�!�=?3����o�m]z�ݬ��պ�:����ϱ%#���(xqZU��B~��:�t��&���^Y}�S�j�������T3~6�٣kZj��E�N1o�s��hR¾���q��\!V{8�[�w	��c��=�h�'+��}�&�v��rYs!��ׯy���l?����Cf���O�� 
�ӝ�[�!��M�{!6�6�u�ͶI5!~
���H�m�r�#��K���>��+`١L�t���pĻ6?s�>\#�
�B,��	����:MЃ��s]�O{�@]�)��������zҪ'����������KB9���)ԧ1������͈ �.�t��PGqz6��f��t@h�s��6����B����������R�+��%:��mwP����QDv�����o��!�|�O��)>w��e��^��Y� �+W�����g�����?F��W��0�������>����e\�7�?�~���W
����������=��,���l��`LOg�������A�z��s����l�Ǽ��q?�g���������s��z7��f�!���L"�[mS(�V�9�"�iHi?l-L�����M�5f�֨�Oڍx���X�4/��0�R%ߟ\���٨�[�(V���j�!��n�����|�X�ߌbޙ)q�`���$[^�NgiҲ���W'˂אǾ���?V|̞;��C�p̐�q�R�D(�7�l�t� �.?U�{��Li�5��&�����7ݑ���@�WVswV������n��������o)(��Oyt@!ͲJ�X�v���ń���)�X�E/\t���(��1���r���2�����������W��6�N,�[��>�m��ɓp�5N� ۡR�d�<�bЎ_����-WՂ|T����^|�������!P���@��E���?�_(���]w��Z���j�����P2�?�@@;�6(����������)x��#^��o�?��NSU����]�����0��?��<�������}}�c����s��1��( �D9�l�Х��X�gCZ��UryL}~L��X>\��[�
�h��ֹB���\���.;��?ZL�}^��޹?��m{�w�
nN�Թ���!=ur� ����֭@@| �:5����;�DgҙI���>UI�"l���{����uNj�G�3�u����;z*��]k4�t]�o���j�t��9>�V{f4�{�Y�b9m�U:�[r�劘��?ݶZ�jx���)4����c�������q��Y�R7V<�oMֳ�F�k���^[�?^l��4���Vْ�6/Ju�����Bhj��1)uLy62��x5������*&-%�h�Y�Z?�z��ʀ)�u�ZIuG��e��8���j��I�.����\��O������7��dB�����W���m�/��?�#K��@�����2��/B�w&@�'�B�'���?�o��?��@.�����<�?���#c��Bp9#��E��D�a�?�����oP�꿃����y�/�W	�Y|����3$��ِ��/�C�ό�F�/���G�	�������J�/��f*�O�Q_; ���^�i�"�����u!����\��+�P��Y������J����CB��l��P��?�.����+㿐��	(�?H
A���m��B��� �##�����\������� ������0��_��ԅ@���m��B�a�9����\�������L��P��?@����W�?��O&���Bǆ�Ā���_.���R��2!����ȅ���Ȁ�������%����"P�+�F^`�����o��˃����Ȉ\���e�z����Qfh���V�6���V�Ě&_2)�����Z��eL�L�E��؏�[ݺ?=y��"w��C�6���;=e��Ex�:}���`W��ؔ��V�7�r�,IO��j]��XK��]��N�;u�dE?�)�Z�ƶ�͗�
�dG{�ݔ=!��4]�ݢ�:肸�Bbfk�6C�VXK2�*C�	���b���q�cתG��<s�����]����h�+���g��P7x��C��?с����0��������<�?������?�>qQ�����?��5�I˻Z�C���Hb1�(�e��q˶�Ӷ���rgO���_�:Z���`�э����fCM�"vX"�h�.�j��oՋ�mXù��5vy���|�TǮ6�Wr`R��
=	��ג���㿈@��ڽ����"�_�������/����/����؀Ʌ��r�_���f��G�����k��(����i=�0r�������M����+bM�ɔ��į�@q��`�r�M Alz�q�%I�ݟE�ݢ��ƚ>��uwR�K"}&V<.l����ة����$�M�Aj=z�\ks��u�]�6A��6�zE�6�l����ӯ��ya�h������d�]��]��OE�;���{Ex��$%N�� ;��YU+�c���{i�a/l>%��j�S(�tj9�����lԚ{�Lkl�,��fS�
��A����*aJ�t,�a�u�]��,�=btywุmȤ֮4����m������X��������v�`��������?�J�Y���,ȅ��W�x��,�L��^���}z@�A�Q�?M^��,ς�gR�O��P7�����\��+�?0��	����"�����G��̕���̈́<�?T�̞���{�?����=P��?B���%�ue��L@n��
�H�����\�?������?,���\���e�/������S���}��P�Ҿ=�#���*ߛps˸�����q�������ib��rW���a&�#M��^��;i������s��������nщ���x�ju~�I�Z�����be�Ì��yyC��Rѧ���!;3��08A���rf����i�������(M���h��s�/v%�Wӫ��#
��CK.H��G��m�>+�Z�[�e�:	�zޯ�L��3�uj�n6#���YMڒ��IV'��f5�������>v+E,D�\0k�0ۻce�2��4�}"8*�bu;���`�������n�[��۶�r��0���<���KȔ\��W�Q0��	P��A�/�����g`����ϋ��n����۶�r��,	������=` �Ʌ�������_����/�?�۱ר/"a�ri���As2����k����c�~�h�MomlF��4�����~��Pڇ�Zy�����E��T4��xOUg=��o*ڴEo�:_�!�)��+Q��>{�fq� h�v������Ʋ��#�s �4	��� `i��� �b!�	�=n��r���"�+�r�0e�U����taQ�{��'�zWRD6,oZr��#�rXa�)��A,�6u�+�ք�b}���n�&�ue����	���O���n����۶���E�J��"��G��2�Z��,N3�rI3�ER�-��9F�Xڢi�T6YʰH�'-�5L���r����1|���g&�m�O��φ��瀟�}�qK��t��'l$���Ҩ��'�^[�V5s���GoB��]0�@����OD��W�5&�X%^�vQ�Z��\�N%�.,OÎ9�z����,�T-+��>v�e7�����%�?��D��?]
u�8y����CG.����\��L�@�Mq��A���CǏ����n=^,kzGVEbNbb�h��r����֢�S�c'�n��?�/��p��}߯0���ˬ	)�c�c�:b'dq��uz@̏-��+>�jFmY7��zDg��q�Ckrp��ג���"������ y�oh� 0Br��_Ȁ�/����/������P�����<�,[�߲�Ʃ�gK������scw߱�@.��pK�!�y��)�G�, {^�e@ae�;m]墭�u���Պ�V���i��Z��Q�E%�S[Ec9+�ё���`���j�<�N���0�P��TiVhm��z)��ӗf��y�&��'>^�҈���օ8e�;��qS�:_ ��0`R��?a~�$��PWKUE҉ٶ�bN��w��1���(%g�)��Y�&��p�/�R��m��^ľ*(�T$�Օ��Ժ��eC�G��]�KN���qmώ-k`y�b��#��`��a�������Bo�gvw>�2=�8-�9����ő����>:�������Lb�}��4�������6]<�gZd�wO����/;����I��{A����H����#��w��_tHw���M\z�s�gSAN>&tB���E�.מ���?�_w�y���n��#J�u����LN�鏃�˃�?&w,��Z��ϛ�����y��>%Q�q�}��������q_��4����������q	]�7�zp"�sq�	�7�������F��^�O�Fs��=�~g��T��4���c䤯v��	=���?;W�$r��Ozd9�t<Z���39��	�����U�އw���s<��lx|����B������������;�����;����UrT��-�$��ݧ�;���|��H* �m��u�?��>���:y[�����|�n�^}�%�jy^?�f�6����	�<���Jvs\CK�Y��x�_�s]ǵ�u"o�������;�R���7�8P���p���k-H?��mt3��4���k����k��skrvg�=�O�y���L�M3 ���^:��~�7·���+���I�L�kaN��0#�X|n<�g�&��ɪ����)%-��"���Ɠڽ��N�����w�v��ȏ���I�	�0��څ_R�ûW5�2=�;��K����������>
                           ����&�� � 
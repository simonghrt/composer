ME=`basename "$0"`
if [ "${ME}" = "install-hlfv1.sh" ]; then
  echo "Please re-run as >   cat install-hlfv1.sh | bash"
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
WORKDIR="$(pwd)/composer-data"
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
docker pull hyperledger/composer-playground:0.11.4
docker tag hyperledger/composer-playground:0.11.4 hyperledger/composer-playground:latest


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
� �ʕY �=�r۸����sfy*{N���aj0Lj�LFI��匧��(Y�.�n����P$ѢH/�����W��>������V� %S[�/Jf����4���h4@�P��
)F�4l25yضWo��=��� � ���h�c�1p�?a�,/Dy�e�'��'�y��o�vd�'�%�U�f�E��Q�C�V}ls�eC��*�ޥ( |��v�o�/ݑUZg�܃��\����6J�Mhi�نVd�`)�j�c{U�;�����MҠ�W-C�A�!�J��RE*��J�L.�~�3 �8� ݄-�՜���PqP�-��j��tGk�KU��%�iT�����9(�č��4ي���	��=@ C��>ff�9ѯ���fw�.kǰV�c��x�#���+l��Te͞ӆڃ��
�3�kXMh!�@�����H���abږ��F"~�0��{�1M�qF`虢WS)fhQ:2�(R��k��ܞm���d��B�pC����5��1��6P���3��`N���^͐cFق���vj�|`�q�\zg�����-��#�ĜQ7�^MJ\�!W�CD���D���j�"�g�Va�怾�,�����au�V򕈧{��-]�F�hR���ԧ���o�CM�a�X1��m�E>nZ�1���(��Y��O����́/|��3����1н*lw������g9�?��B\����y����g�E�i�v���R ��� J��i��y��ǤX�?��j���pE��4��{`��W�L3d��#f�Mk�/��?�}<��T����o-���/�ȿ)+]���ۆ� m����E����
�ư���n��� �h�����@�X��$�(L�	^�oj&�@����1 Y��y0���&q~��a�mWj���>���`��d���ڗL�c��$ɮ�1�)�����
�m�#1s�8/��h�׼�m�I�P�JGF�Fo3IW��]�����Q�h۪�c���^��w�t�U�fH����'�t��L
�?���Ep�0z\��l;�����h8m�Ij�}�zYl�{��,4�~Nb*gT�o�u�Q�_*ܲ�5-M���\`�q���8�1(�Ck����뀠�G=��-W'Nq�tdtUM#�ڂ=�Q"���޾�(`S�B�c�/^R)��{��IX�6���R[��&YdA~�h|x��ԑ"�J� �j�-�fgۡ���D�FtWӰ��k��Ij�Z*j��l\����zwr��2�Z=@*�n�
�bf<�Fp��W�6@T�x�<2f��D��?L��b½r��b�{d�2�;��|����B7p�Dfު�y$��F_�~�,��)2tmH$0�>:7}3���Ź�+l�z�WE���C
aڛ�9t:h�<�ݣ5(��P��U� �X6�g@S�O{�aN�= �i�!��cN��藔_�P���ͯ��/h���}Q�M>'8cg�t/�8��aA����5�T�cDoh^� �!<x�:~:�e�j:ܬ�_*�Y�1#=�����d�����|�0G�����X �,�ŧ��������v�x֙�� �d�iӦ6�,C�)l�f-��i�e���@֏a�t��wuBU�s��J��;����&�c���]��l?�@���$c9t��܌�,�Rgu�\ɕ��.���f��@ �\݆Ώ�H��n���A�8r	L��t(����:Q�x+��|2�w*��V�b�zV��R�z3�h�hg�h���˙.L��c��.����_�1�ćW�IT"�;��x>�὿��>���7��������Т���s��Y
X\�ɂ�N��?����]�_��κ=����"��Y����8����q�YV��8���끍��e����l9�\$�Q�����8�k#��/�Գ�Z}�t�TM���Pȴ`K� �uU<&�_�7Z��0G������z�g���6����w8L8v>X�����'��_,?�w^4�qa���Ea��YL}���.���ܲ -˰~����A�ד����<����wv �j+�!_�Hݳ_%�o
��Cہ=���]͉� ��������/ƨ�U�`�0u'�5��@7@Ѡ����XL�Pm�����c�G�kp}^�N�QV���{�(�-�WeG�(~��s�]��A3���=,x��3�����>W�_�#�]?���=��d�8'�;�� ���&.<��F��^���b|�	�afT
7�t��1=j��Y^���Yx����N�?���U�A�.՘G7��U`y�/Kb� �{͕�X��0�_�2�_<{�G쓀}�漕��F�~������������/��F�����������q ��70��GTR�.�-@�\�J���O@*e�ϫ��B�Q�ɝ�%.�8=�C�jV��v&/��E�:���!W�܂7>Dn��w��FG�SW�<��_*HW���Bi��XV����2��E��7�0�ɢL���И��̃k˘�F֑mЀP�'�9減���oE���x���U�?����m,��X>&L��l|����B��
��f�=^>7\�Qwx��6�TD]m{����.�(0�V/\� �R�R���R♈���b2/���1O ����N֌�b�]Sہ�h�`
�S�`J�h��y�@�T��%�|&��e�Rk�RZ�J�*!7�V/���K�bu�����#}يX���Q�F�E�l6W̞奺��KK�Zv��\z��L��A�LB�w�	��(�����հ�e�+R�V�UO&&��r)�G������.Ma����^apb�*�s�lT�����O�ژ�)`�� 4��`V�ф޹d<�}Cs{p\ϼ)ڝ�����a��]Â���ش�'��7��������������N׼�.\��%��9��� l��fv�n5S�6Y���6�K�i|���b�o�X,z�b���|�w�y������Z2�����{�7�?k�e��>��-��0,75�Ѩ�n��:�s��{��Ґ:��xvQX�+�-a �#�D/����Գ%�`D�<��/�!rU���؉[B�t��X��kn\�Ԝ��O����\
���g�c�/p1O�o���>_��8�9�0
�a�X�
(�j�
��+��/J_��U:��d�;�����K!�����6��z���/6�-U=��q@cL�6]��M8��%D-+��9�@�9�ٟ���qn����+��r�òQk.<`�C`Xm@�� �|�zg����Gp]�R�9#�o,��Q�r��_��,�����G��pC�C�Ol������L��2� &_Y���U Bb����E�>�27�b\d�)S��7D�]�Kh��'nnz�&������-:��o�-~���?�pwhcu�?g������_+1O=���Em,���i�O���_���|M�Q����?|���_������֟~����<��i)���	��h��N"k5��eȳ���F"�+2�	���Ǝ l��W��~EMW����7�O�ij*�_�!��t�O���m�ɷ�)*e�a9����׭��F��u�������d5�o�������y;�����?�[��������R��[�z�2�i�����0��~�kX��O=�7���O,ܕ�X]�G���_�q����-������?/�7�-���cX�o5�&J�4h� ���0�i�����=�A�\��|KV �g:���H�j{�rd��
���``<�h1J|'��v����%�sQe��NSf������D���rB���&�qmi"U��k �NCR�� %���L.%V%��^/�r��y*%*��8�%�v�,ݒ^/�6#���xW��R�܁q��<g$�;P.�<�A�fE�&%;�T�^��.�r�]�����n���j�F�+K�s���)�t���{]�e�N�<�v.�U�aT�lbxz)��o;��ۤ}Z�s��e�P��b罞����w�b����9�P�1�j�;�i�$���׏ϓ�=H���GGYi�^���4p�w�d�������i_�	�IU:.$���_����qs����X8����R��d�8��X�X腊��l�Q�Z�W�7��S4��B69�5[)�	�-eS)��@����̺;�#6۽�Tu#ߏߪ'��K�q8.W�$��|���ʵ։| d�fEU�B�4~j�;�J<g����)/����y���D����H�����~;-�X�I��#��XHٸW���[H��d�:��x2�L�׭r�;8��j����R�bR�XA�����݂h�{�f0%2m� �R��o���)��k�z��2!'"��U<�`E?��~�i��� f�o�M#cH�,��Dܭ������2�S|"�okeq�NX^*��}uu��#����W�Ǌk���O�eX�n��-��l��=�G�gF��2�6�E��Q���_��/:}�o`M�`����eYas�s-��˹:Z��tBR�R�\v���mkt2�dlC�&7���I��F�)uZ�L�}��cM�k�4T.�G:�v�ɕŲ�O�G�b�,Ժ�9uY�{)�xՀ��_�ֆGea(d4(���\Vm�:�z�0�j������t����U�`��1
���x��ا��>����]������d����]����c��������Z ��ג�\*��g�ip��?R�������Q[�����2�\ͼ)\�݈��7mS>�E�RF)s�)t%���ӷn=SNtC4�&{p��^:�����������7�v5'����^p���S���� �C�1p`IKm���� ,��X��>�#D�����3�2̡E�'s���e���i���lP��/�a���<L����C�/��Bk�Z3!�Pmtɋ@*Ym�!��-UWIĔ��Q]��^��z�.��5~�9�m?0Iz�����7�u�@Q���@ ����� _E��m\#]1�Bf�!���(�Ԍ	AªF����B��F��7lG'�����3�Ks��ڂ�f�%�ſm�Q��T͹�၏;�VM�A�8��鐗��/	C]nhп�G;�� ��D�
��k��y�k�
P�'������q���I6
C'$�߾�0�B3�&�e��n{�OJ��m�����xl�jw�����n�m�����`���$��\�8 !�]�ZA�p����p���x3o�(������_����_UMM��юG���0�(>`)�;��pp��f��`D��,P�(�˚h�	ys����lSCU���m��U貫oohI>�+�SN/��bk?���H>'M02��~Q��d�̌�36W�� �\䠜l��<t��/A�<M�Ǜ��?�г2l� ݓ�>wzG[g|�&�+?{��������/g$?�w%�nb	m~��C�΀>��M�!�j��m���T!���ɉb��@�)���ކv��n�~�0`�6t:E_�{0�̯Ӕ`�C�h
Q'�Ԑ��\�/
�,��[Ʒ�	�l��&��/�ϸxx��v���=�n@(�Cc���o��6�#����<����E-�c �j�j[�srE���ӑ���]ۘB�X�%��sS �!���c�����pt ��|$+s�1>"���m���S���Td��ɴk9���<������
��پm�[c��.N�)4*]}jB-���k�BJ��w��&ݹ��Tu�����:l�%e�-:d*(�.*��|~��]C�5����#��8��C��FG���Ʉ��Rhݪ�2����Wu����&��NM�-_�]�k#�Vt��I�Bodk�)xcsO5����k&ѷ����zh�@ү;���?�E��d�����W�!�v����>�V����?����s���������}b�_=|����!E�6E�&E,�_�y���w����~���gRh�g_�c�DF�JJ���D,���R/��e"�x����� ))���xFN�	������>��_O����O����٣�;������;}e�~+B|?��H�? �^!k���}���@���=����{w�������y�����V��1�j0�=�X�-J�~:�ܷ�b��$̳�Ͱ������Y�Z����D +�+_E V��:��Bm;���
�ူ�؎rSb;!���ȼ����Y{.���Y����V��� ̳K����"��B]�9�i<g��vk>�3i���z����Y��)6!��Gž4,����L�윍	��9�ߝ����v���|sڎf,�n�yӰ7/����7X�&5hW���}~yT\0C�t���&�IX�x��G��*��&;�M]��\�Xk����/s��A��3%_o&!a��=!�YT�z�J�
a��}���Ơ�"��@���C?h��1��7m�ϖ���jq�WkjX�y���B��"}·D����F<9��'Ƣ�z��y|���!�:ͫ���,�7�,�8U��y&�'��Z�����x֔�l{yT��Y>�w��$��M�N�Giz6��ben&G�X9����f#�Z���.{�{�6�~I�}I�|I�{I�zI�yI�xI�wI�vI�uI�tIl�\^�̻ě����&��_�(��}��p���g��%�,�;��-.������Y���В��%�|�]\��B�֮�@��v�'m`�=ܼ�
�s?��N��e59E��Tq�3��~�*�,-�i����B��x#�*D�$GͨpR��s"���d<��N���L�dBE��m�^�������y���to?Kg�@d�\y�<�DM=^� �liSݔ�'�X�vn_�~Jta�T(b��2I��j®�L��s�vK�h�D�*��� ��'�=c�raU�|��XK6;�ʤ[%�H��A�����!w����{��"��[�����G���[��7v^�}��rÿ`o7�s���e7��o��x�u6�e�<����u�OC��|#����}v���+����{���
����z#��_�˲�~��'�~�Q��$�B����?r��?x���<��?�֔��Д�`��y+=����T�֢̥�'I�׽����}~�����F7��k���rv�<�\�m�f:O�r������pLW��T�t�֦>��g�+��#�(-���:�Y9�alɬ�4�Q�1K*WHM��dq�W��Y��$����H��re�va_F����M�١�t�q޶�8m�{���0WT5~\<6��M��tű2i��[m�"�;mFms�;���`<��42�����cAf՚�d qˡ��aU����~�x?��@�8�h�`۹��o�|{����5G��4�p�Fk'�bP=�K��o��TDTNR��IFj$!�k�pд�BTA���Yc{T�ό�~\W�;�Q�ş��./��d�����⁽_�Vi�(P��@��.�y�9�	�R�K�*�:�ח����������/mȹ%}������#�k?aE.&��E��[�����0�w�X?�>>�J����wO�	��m�z0����>��o��rY�-�d��Z��5S�^-U���)N���65�r)�?hi��Xi-s6N0��bu���������W�QZ˞2�l���e�3��p�h�	�9'P�
4m9�r�dk6o�jk8�Z��y5W��T�7�O���GpN'tU"�4��c5�/
\u2���>-��Q�$]U�c�XhĦ<抍ԬH0�o�yG�
�z]�
��b<�/�{�lA�����52}jP�P����%�tqY{�B1�_]�e9��ʑ�ٰ6�h��@e���1�BTbK�u$���]G2�y�N�v	F��ؙ�]��	����t& N�<gRG��P����z��(�b��q�(;�7�z���đ�r�	���\֤{�hz֩5x5�-��1t:�h��	�*Q��l��|L_��3�H/��Qn�Pϣlq(�f�-������hi���#��g�B-��D�]vB@\(���w(L�_�i�R��DM�O��|ܢ;"}r��W�ِ��фB�}8�d�f0vcގL�P�&9�j�H��q}!v:�V�Qa�
w�2�ail�>}c��@\�n�`���E�7������c���w`u��s�Q��Л�Qӣ��e���Ӛh΋�ЎO�+�/�_edNMq1VB��"�4��I����e4��zz{�x��/��>��K�o��JZ�6z�x�y�qPD�ƓŇ�M�4��1��1�5�9��2~��>!�/ ���TZWH��ОpM��֧�/b�,������rN'X4;�?���<��9�,O�T�P"�K|��o��^��E^�tn��Tv�ל�����s��Od�o�şk��E���?ģѯ��������+��%p��wӤ��)�j���ϝ\C�y�ܙ�!)���͗�>$F��a���d�
��L�P��Ή��hW�3tT��n�ww�!A��&�i���;��Wצ�����w���'���0�*At�z^���R��4�u=�ŗ�Y^S�_���Y:��pK%�����"���[�V��uÁ����b	� �\ �?���a����(�� �s��~��L]��3A���`����1�7���q���m#�����.�51���$y�4��T�ɑ}jv��4���ԑ�4�<��_P�Wh5��2`	� �t��d�J|L��'X]T�`�2���Kt�lC���§��=P1�w������y����rn<�L��sER@��j���Y���6��49ׅ���w���m��������\�46���C8j���8X!�"tb��Ɣ��$�2(0�N�QW�����s�$��T��ٝȾܺ#�;����M�o"lo.z������}c��lX؏���z���aS�����"��+Nx��0M|ֳ
�hc|l�t��h>��Ŧb�4�Zc�"ZW�����p�Fb���p,��Fʡ̭5n���"rؼ�p�BR�3����pY���Wۀ��5.�oD�7�c����$��G&p��l]`�Һ[�&�������~��)���w���p�I�r��8�
"$���x�/0���Pπ�;�1`N���0�wo z��N�"��S�?�^�{٬۫.^� ݵ��`�P����dTO�`()=�Cm#
H	��|�.�d�\�VIP�5�&�nn������F)�k��W�1�5����bf�`���m@�ce2�MA��@��qs��B�K�%(�)���XfaA!;���/�+!*t½a;x�	D�^�h@�͒WU\U�`e��"`�n��4)0��Uq�6�lTo�?x��#i/|t���cƽRa�n��*T� �5&k�v����7v%�%�\�!=9��L�r�ºf�q�iH�y�8� V@Yݣ�� �rE��䫇�vh�_�M��6�4M��t��L$]Y���<74�h���N��%p���N(-�D�w1�n�-n�0R,ۘ\��)�t��~�ոp���g��'�f������ް�_�����]���2����HES����Qg���翾��q��F?%4���l�sñ����Ûܕ��3��F�����i�>EWc<+V7���;(�dlp�c����i�bKm���ʅ^����
_M[��?E'���k
:��/V�FeЋ%�R )��D��)�D/��u�J��S=
����g��ԓz�$���
�&��9p,�{���{����^���>��K~�Y'�%��T|iȍ[��C|�9<���XR %@��H<I�@��J� @2�(�H:�Vb@�� %��(�B�$P�`ȧ�s�!�;�ɧ�X3�����/<y���M[�v�{�٩�Qn�(���&[�o!�Fe��>x��V�,W��:ϕ�:]:-U�%�+=�i�^N�7D�L�l�k4�Ep|�����'*�3���v����/ٲvE��tIhTy�Y`��:jt�Յ*ͱ�څWV����TF�3acl�U����I7�jV*��t��ֵ�;�b���I�3s�2���}q�z�Z#{��;𖁈p��M	�ҷ/�l�W,�\>�/�z��V��y��?�r\}c����͗�vE�(�1��:�pʕ�j�/�Ϧ#m~��V��L����� �9Q�pH^������q�եͺ����Z�4�l����eNlU�Gl�3O�N��v�]�gM�"Lu�Wi�pQiP�}mYu��aކH���E��ܳ,��e���V�����we�ik��]��S��y�U_է	 �b��)M�y�@������Ďo�ĽN�b������ݫ5��;=���z��I"�[��/�-_v��+��x��m����4��3L}�H��c׹c?z���D���=���{�5=[�������?�jer�W�t��Q���Q��׳��ٶ/�xK\���_?���|swZ�%�܀_��;|�)�����3�ϻ���"�������_>����us`.A�+�Ф@�������/(����}@�|�+���O�&X���C�oY��iX�����n��I��F����y�o
@ ����i�$���i�|������T���O������'�G3����H �3`?�3��~��G�������������_I�9
ŤH�1����Rd�.�#?��
c^$�2��+��K���Gݝ�8��O��?������c2y�g>*&�l�\���!J��hS��^FIy�b��4nz{���W�fyÏ:z�.��^��t3�{��9�}ѝL����P㟆�p�6�N}8�&��v<��=������,��<�~<���ڝ?8����/���!EO�}�X����I��(�����?�������E�O������&��	�?
���2��/���?���O	����H��_;q/�@�%B�������o���G����#�_�ET����O��o���$�9�0��t��%�����S�	�H���}����[�a���M��?"`���Z p��9���� �G�����ǋ/��Z=h�E�-e�T��t���m�穐���TVO���K�'����k�Y3���yi�$�����Շ���������I�l�⇊&�fi�85�Ge57�r�������p�6�Sf�W[��y�ɕV��wj�Y@�O���w�M����?���/�}>�}���Y���FH��Fg��+o�͂��\>^���6�cs������þO������4S����q��9w*M�.�-%kVM�P��]���<t9���7��ե(���m�ٶa��N�#S�N�oK`�����0`�����(�n�����a����%
5�����?Q0�	��	����	�������?�
`���I��E��ϭ�����{�{���Q +���&�?8��P�_^������k��=��}>��O7�|���U�/>�������!��s��;���z���v�殅�>��������dd���0�����%�L�7���/�F)g��b$9��$M\nj}~Ķ��6X��S]vx�2�������l��5��zTS���CH?UT;7V�w����9�k���/���Xn��v��#����>��e����p<3��V��*W�J:�Dnu��R�U��x^1Փz%#'idH���U��-������ �G���?�@���c���1�� ��ϭ�p��ٽp����$����Q@	ሣ��䩈��9��� &c6!�0dx�煐f��dB>��	Ș������?��h�;���S�kLe�.W�O��T�oO�a�����kӊ9�$AU}���E1r�{�3��x��<Io�Gu���u����v68��}�\�KFҭ�%i�O4�m���1^E���pI5�-;Ïj���Z����gq(x���p�[(p��!�+X�?�����s�9��E_�O����;㿝e��]C/��DHb�uF���xw����r�yӐs�t�{���&÷��������)_��V��3����$TՃǒ���$)c�W��sJ�y��F�R��/r>O�v��e������A��Z��Ӑ�-����O���� 꿠��8@��A��A��_��ЀE �'7��,	A�!�K��;��_���o'lVUe?�-B�Q�D?o���i!��'9z���,;)qV[���  �/�c 񭞽;�,U�joN�J��xq�l�G+��6�r�����i��g��ێ�v�RV��hV�S��:U�ҥ����Bc �QI଺h[��K�Y��۩de��4�H<����'�_���w���e��V��T���VI�r��<}����˵r��c���)Z R�l[��ӂHQ�-�i��6RSM:l{l*%��T�����/5������B��m��{��ݭ+e1��O�R5e2�4��$V�h���t�j�eK��Y��G���y�X�5��m̾�'Ţ���[olF2ލ8�?����X�(����C��@��/������C�
���4y����� 	����@������	$��( ��������_�������$?�9?�I!�#��ِ�%��y��b�y1f� �L����D)f���y?�������_N��$����^+��N��冋�ץ	nн��4+g�֦Ǟx�dW6?��:-��}t�;5WK�ꑻMMܗ��\0Jk=Y��A�����Z�=��]v�x����j���R��U%֫t�-�YT�����a���;� ��������%�G@��o���4�������?��!����<�q�?���O�7�?��C��/_~�/cT����� �?x���r��_뿭]kٳJǨ�T���0Y鳹}S��
���d���[��1����k�{j�/G��Ok��o�;�����'ՊG�X�]݉��bS���隽Us/X�ɰџr���~�[Wj����w4�r��G�d�'x�\-G0R3jwx�Տ�$oL�]�i�l����j^�%�+ʹ����w�b(��4gyc�Y/�84�VkK�ޜ�u�����*;�M�U[eӆ���l��0fE�$q}�<^z%A3��Y�ݼ'�ը���5��ª�Ue��}��MI�9Ġg��>99��$�#���X�e#���`�oA@��`�;����s�?������Z��?����;��<�H ��P���P�����>N�e�R X��ϭ�p�8�/����#dp���_����������=����M��C����w���=��b���3�#�O��m�� �� *��_��B� ��/��a�wQ(����` ����ԝ���H���9D� ��/���;�_��	��0�@T�����? �?���?��%������B�"`���3�@@�������� �#F�m! ������H ��� ��� ����
�`Q  ����������9j`���`��	�����������?�D�_:I���(@������po|��0�	��(�G���/P���P��G��������(�(������4[mc� ���[����̳{�?�N�OQg1���#2D�G��B6C�����8^�|2<�D�S��K%���,'��~����gx
����M����s�?}��Wk�S�Y�T�ܿ�l;!I#o6��jR�&��'���#j[��|��W�8<u��ލ;���rg�WS۵:kӝ�*�*�N=v��W� N�7s�v�;r�y̹�]�$긿tW�]�EǴ�e���Z�KƋX1�+S���|��/8f�a����P�����ԷP��C�W����)�����s���8�?���w��1�C)ku�Ji�XY�9��ڴ�:��߬P�Cv��������,sv��:��V�Ko�c#��w�=�I�ڭ}#�ԡbl��p��N�4�Uy�ޘZ����r��L��i��=�9�����f�;���?��	����C������/����/����+6��`������?迏�K��u���~�J}�cԾ����N�{QI��_��*�����"�4�S�*�f�u ��?f�t��u7,���L��S����Q,i��?1jiv�ƞ�6�>OvR��;Ic�O��)�6#&��㤙�k��vZ]�J��*'n�]?y�����ҩ��ۭ(�����������I��,Т}�VN�vlU�=ED�m�rZ$�(֠�8��b�Fz�,ʦn�FM8�F��񑦂� `&bdd~y�#���9��T�6g^C�(Fg1�Rj�+����<+E�L��um���݆��G�5'l���������6��Ϸ�����_�(���?)�p�����|�r����)X4�!���;�������_ݠ�[�X�_���H����i��=�e��Q �?�z��~@��?��������C�^��Y]U���W���/��r0v&%)�h�3��	\h������Γ��J??,]�Շ��v�UOg�s�s?�j~M�o����#����\O�|��y��7��)uٹ�./�ˋk	�mI�+w�$|̴�׬��(���Ω/��u]J���։6ט���ի�l���<���޳#��S�����,9C��)Y�����z�*3?����O���AWn=ъ�T�5����s��e͕d�_~�5����#�o�_�keS�����EU�9�n��bo��܏�N�����/�l�4��C�m��Ϛ��,sb�dM��B��GT���svp�Q\���^W�C[�/vNs1�rJ��(��+�s�;��2�DzzYc�Ǯ�}�ii����������n������?!�Ȁ�?F"�Ҿ4bB�?���4"Y����(XF���!�q Q~L�T�����������?$������䚗��$�$�{�v����뇀os�(�Ǟ?���ʕo�
��rQ+P��Z|��I��������!����A�Qs�� �����a��b������@�!�K���������Lܷ��Di+��������E����cA��s���%�F�-�7�R�G�'�wI����L�}�����~Oi?�uy?��dN�VNT����]i��ؖ�ί��U�x��2hGWG ��<ttd 2� �ZQ���zͼ�Z�YYy�J���H/ �Q�Y����a�4O+��3�U��=rzh.k.�麘��e��z�i�4˻����G�ɆUsz���b9��L�a?�[����~ȝq?Uήñ��cS*�2�D��ݱ�u<���pkOYy�>�M����̌Ӻ7�4|d�]w�c#cƐ�Y7	Q,���~�Ǳ�4��������~��Q�������kM�B������$3�������������� ���Ri���Zű�Y%�t�O��Wc��Q*�V�*���]����8�l���
��!������_�������{�����%�h���8�Fȱ&̍M�|$a���.��#���e���eK�Z�o�-0���x��?5����?��a�/A�%j�V�a���@Ͽ����
���?����_�!c���@�tPa�����v�38����K�?|���}X��?WPY�������nh����������mN��?�>_�Q<��뺏u�c_M�D9���J�>?uV©S_�:�m�M�l��OVB�:s�|���u�
y^�r��_.�-�ŵ6�����Yx!�}�J�ZF�3{��R7�V��K�hߙ,�}��Z^O���7�gq]'n�2�E<p5���]_�^��Wkt�a��|�鴅�����������pY��o�lܼ���8��[֚��6���=R����`m�}��ڻ���m�Bn��'/)���ar�A_�ٶ�o�jϐCiLף���!sP�bʱ��m�qF��Z�Y�����,0��{�8�5_+�#�Om���G�o��(������?� ��_W!�/* �l�W�����C�����C!����O����L ����	����	����ު���!�B����E�����?����o�ߒ�0��	������������[���տ�K��!������$�6(�37�����������
������N�/��f���?���������?�����O!O�_�����;��w�����@A�|!rBV�����-���	������qQ�������L���������c�B�����?2B�*B�C!��������!���?���?��?迬��B���[���a�?7���"'"���H���3�?���?��C���w�`�'��Bǂ�����c�B�?y���2A1����B!������������(���h���	y꿵q
�m`@�� �l�W���7�?���
��:MกiUfI�z�$z��5� uS]��*eL��u��MS����4��Th��އo����Q��з�?��g�W�o O�������_j������ĝvҰM֒�%�yN�b5��-�>�}�W��v�s$;�Ju�&���:�pMbE�����NW�ڞ���I���D�ۍ�!���c��'k��K��(=Pn�����߳D!�q��^e��;����y���Qm��}�����T�^0������W�m`ַ(B��_~(�C�O~ȓ�/����y�����_~����ZmBڋ�1Eg��L��t#����̻<����ޚ��_S����Nw�v5=�����l�R8�G�'�M�*v{�Ө��i���ʉ��I��n�L=uI���B[|���⿯E1��
���<�]}҃�Q�F(D�������/����/�����h�Q�G�7������_��{�ݏ��۱�@�Ck���đn�X?����]�}��:'r	��5�����!�G�XLf��v0�SFu��贷��T�&ˮ���L�#���̌��b�9��~-�d[a����: v퍺�+j_�׫a��(����ܮ͒uvI�O�J���峖����d�%�\_�?�)�s����^g����RD ǉ��˛ۂRg�+5�kɇ��|r��D�X�=�;�.�p�/�b�`�����8�n}�ƭ#�<Ϋ��#�X=��0�侘�3lW�$ڝ���?�t��%L�6�*;����5���p
����[��/@�GA������?�&��¤������(�3w���,����x��}B� ��ϛ�	�F�S��r���,�xp ��������������E��n�G�?���O������LP$�����9�Ǆ�	�����������(����������?X2W@�������?���?,��
�ӷ���d�/�����c��U�Q�p=nz��`F/M���Ce[���b���#��k?��
��j�ϵ�!��#-�@���w���������:��|]�o��D�F�;�b���<���~�W}�F��项��x��b�6o��-����,�j��R$V��y把�Ⱦ2I�~�o�����"w�~UM8�Ǣ�ÎM��O���v����T��í=e����6��u��33N��L��=v�	���C�g]��Y����]�ci&gmkݍ������6�6�1ʋ�ך�+�Du����If���B���n�]��Z<�xD@����������H���F2E!��;�_��g���/����|��rB����"�y7�C������
��	��;G� �[��?���/���z�����Q�M�͆�#Ǔ��c�ڳ�5�/Z�}�?�%�:<�9��`���ӵL�j ��?>� T�N�N��*a7�r]�Q��*�b�w�mY�ww�1�����U�~����nW&6J��Q���꫚��&���  i�_�@�"�?��l<`ek�ܔ��}\f�h����d�c&!Q�Űv�:���y��ۑ�c��C�U�tԎC��h���3�߉5�����oF!�~g�����������	��[���+���
�(��5���
c������j,+�F��Ѥ�S�IX�fP�nb*��&�C�*C,i�}�V��E��{�B�6�����3tH�����9#	;�����&�a8[����yT+_��<�O��6VY�Ub���`o�7DZSrl�VEU;��R��U�(���9GI8/�t��X:	�O=lՏf���ע�?��\��t����Q����P����ܐ;��,���y7�C���_~���?�o��J�z�¡K��kR����7�"�C����N��]�?zȟ��x�#|߯����#7(��B��4&��L�A������V�+Fԕ4��|��6��?��&4gG�$ ��Z������R����#��_Wa�Q��/���P��_P��_0��/��Ѐ�����*��r��4��Q��lݧ�ޡg�D[M���nR������{�o�@���(��p�n:کj��;�_V�8�O����k[4&��ȧ�F+�jQe�Mg��v+]�\�gJm5u?T�^]�;�.�Y������CR�ǩl���<��^�f<������`(�����m��z�^����Dr��5n�ժ�EcM�
2��G�kn+Q8ciJ��9,F�˛�\�V%?��b�lt��TH��Ƈ}��z��8�#��ӄ��(��K:�L��g{+Z!��ic-Nsdnc��Z-��)}��ZԲ�>=�	��Z��������y��	�?���6�����,������_��L��'�O�t������2�R����(�{��y���:�n¨GD%��2����=v����޴�\���������t6F���t/RAJ>&t�һ�>�������Ӈ��;��IKw��y[�<cs=��l_�T�lL~���k�^��~�R������D����s���?��?�	:��������@5�C55��%��D��W2� �JFl����񢒺٤O��z��		����8��U+E�Q��A`$G.��УmpB�����~�WI_��������_9v�x?�������S�?*��%?^&���"�o�59�o?}x�d��B�<_6�ޙ����tr7��6����{��n��g�&mcn�R����XZFP�<�h[z~B��OW��o�K��N�+�{��Y�MBQ��v�w�	ýQ��T�#v0z?��Bw<��7j�~��w5#����m��_��n��ݽ��]H��u���垓k0��o��,�u����z|I���ݶt'��/���d?'״�Q#�Q�c�Wv�G���*[���KJZ��M<}r��{�0x���nG�����"�"�}��e���?)=৯j�Uz���o��+K�OO���C�3    (�AV�� � 
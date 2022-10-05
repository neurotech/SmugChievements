echo "Building SmugChievements and installing to WoW directory."
touch SmugChievements-Retail.toc SmugChievements-Classic.toc

cat SmugChievements.toctemplate > SmugChievements.toctemplate.tmp

sed -i "s/ADDON_VERSION/$(git describe --abbrev=0)/g" SmugChievements.toctemplate.tmp

cat SmugChievements.toctemplate.tmp > SmugChievements-Retail.toc
cat SmugChievements.toctemplate.tmp > SmugChievements-Classic.toc

sed -i "s/INTERFACE_VERSION/$(cat ./versions/retail)/g" SmugChievements-Retail.toc
sed -i "s/INTERFACE_VERSION/$(cat ./versions/classic)/g" SmugChievements-Classic.toc

mkdir -p /h/games/World\ of\ Warcraft/_retail_/Interface/AddOns/SmugChievements/
mkdir -p /h/games/World\ of\ Warcraft/_classic_/Interface/AddOns/SmugChievements/

cp *.lua /h/games/World\ of\ Warcraft/_retail_/Interface/AddOns/SmugChievements/
cp SmugChievements-Retail.toc /h/games/World\ of\ Warcraft/_retail_/Interface/AddOns/SmugChievements/

cp *.lua /h/games/World\ of\ Warcraft/_classic_/Interface/AddOns/SmugChievements/
cp SmugChievements-Classic.toc /h/games/World\ of\ Warcraft/_classic_/Interface/AddOns/SmugChievements/
cp SmugChievements-Classic.toc /h/games/World\ of\ Warcraft/_classic_/Interface/AddOns/SmugChievements/SmugChievements-BCC.toc
cp SmugChievements-Classic.toc /h/games/World\ of\ Warcraft/_classic_/Interface/AddOns/SmugChievements/SmugChievements-WOTLKC.toc

rm SmugChievements.toctemplate.tmp
rm SmugChievements-Retail.toc
rm SmugChievements-Classic.toc
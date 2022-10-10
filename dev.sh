echo "Building SmugChievements and installing to WoW directory."

touch SmugChievements.toc.tmp

cat SmugChievements.toc > SmugChievements.toc.tmp

sed -i "s/@project-version@/$(git describe --abbrev=0)/g" SmugChievements.toc.tmp

mkdir -p /h/games/World\ of\ Warcraft/_classic_/Interface/AddOns/SmugChievements/

cp -r LibDBIcon-1.0 /h/games/World\ of\ Warcraft/_classic_/Interface/AddOns/SmugChievements/
cp *.lua *.tga /h/games/World\ of\ Warcraft/_classic_/Interface/AddOns/SmugChievements/

cp SmugChievements.toc.tmp /h/games/World\ of\ Warcraft/_classic_/Interface/AddOns/SmugChievements/SmugChievements.toc

rm SmugChievements.toc.tmp

echo "Complete."
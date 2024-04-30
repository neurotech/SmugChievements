echo "Building SmugChievements and installing to WoW directory."

touch SmugChievements.toc.tmp

cat SmugChievements.toc >SmugChievements.toc.tmp

sed -i "s/@project-version@/$(git describe --abbrev=0)/g" SmugChievements.toc.tmp

mkdir -p /f/games/World\ of\ Warcraft/_retail_/Interface/AddOns/SmugChievements/
mkdir -p /f/games/World\ of\ Warcraft/_classic_/Interface/AddOns/SmugChievements/
mkdir -p /f/games/World\ of\ Warcraft/_classic_era_ptr_/Interface/AddOns/SmugChievements/

cp -r LibDBIcon-1.0 /f/games/World\ of\ Warcraft/_retail_/Interface/AddOns/SmugChievements/
cp -r LibDBIcon-1.0 /f/games/World\ of\ Warcraft/_classic_/Interface/AddOns/SmugChievements/
cp -r LibDBIcon-1.0 /f/games/World\ of\ Warcraft/_classic_era_ptr_/Interface/AddOns/SmugChievements/

cp *.lua *.tga /f/games/World\ of\ Warcraft/_retail_/Interface/AddOns/SmugChievements/
cp *.lua *.tga /f/games/World\ of\ Warcraft/_classic_/Interface/AddOns/SmugChievements/
cp *.lua *.tga /f/games/World\ of\ Warcraft/_classic_era_ptr_/Interface/AddOns/SmugChievements/

cp SmugChievements.toc.tmp /f/games/World\ of\ Warcraft/_retail_/Interface/AddOns/SmugChievements/SmugChievements.toc
cp SmugChievements.toc.tmp /f/games/World\ of\ Warcraft/_classic_/Interface/AddOns/SmugChievements/SmugChievements.toc
cp SmugChievements.toc.tmp /f/games/World\ of\ Warcraft/_classic_era_ptr_/Interface/AddOns/SmugChievements/SmugChievements.toc

rm SmugChievements.toc.tmp
echo "Complete."

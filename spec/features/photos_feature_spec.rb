require "rails_helper"

feature "photos" do
  context "no photos" do
    scenario "displays a prompt to add a photos" do
      visit photos_path
      expect(page).to have_content "No photos yet"
      expect(page).to have_link "New Photo"
    end
  end

  context "adding photos" do
    let!(:user) { FactoryGirl.create(:user) }

    scenario "allows user to add a new photo" do
      sign_in_as(user)
      visit photos_path
      click_link "New Photo"
      attach_file :photo_image, "./spec/images/kitten.jpg"
      fill_in "Status", with: "Fluffy kitten"
      click_button "Post"

      expect(current_path).to eq photos_path
      expect(page).to have_css "img[src*=kitten]"
      expect(page).to have_content "Fluffy kitten"
      within ".creator" do
        expect(page).to have_content user.username
      end
    end

    scenario "guest has to sign in before adding a photo" do
      visit photos_path
      click_link "New Photo"
      expect(current_path).to eq new_user_session_path
    end
  end

  context "viewing photos" do
    scenario "allows user to view a photo" do
      photo = FactoryGirl.create(:photo)
      visit photos_path
      find(".image").click

      expect(current_path).to eq photo_path(photo)
      expect(page).to have_css "img[src*=kitten]"
      expect(page).to have_content photo.status
    end
  end

  context "editing photo status" do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:photo) { FactoryGirl.create(:photo, user: user) }

    scenario "allows user to edit a photo's status" do
      sign_in_as(user)
      visit photos_path
      find(".edit-status").click_link "Edit"
      fill_in "Status", with: "Fluffy kitten"
      click_button "Save"

      expect(page).to have_content "Fluffy kitten"
      expect(current_path).to eq photos_path
    end

    context "cannot edit other users' photos" do
      before do
        other_user = FactoryGirl.create(:user)
        sign_in_as(other_user)
      end

      scenario "prevents from editing other users photo status" do
        visit photos_path
        expect(page).not_to have_css ".edit-status"
      end

      scenario "prevents from editing other users photos via a update request" do
        page.driver.submit :patch, photo_path(photo.id), { status: "Hacking" }
        expect(current_path).to eq photos_path
        expect(page).to have_content photo.status
        expect(page).not_to have_content "Hacking"
      end
    end
  end

  context "deleting photos" do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:photo) { FactoryGirl.create(:photo, user: user) }

    scenario "allows user to delete a photo" do
      sign_in_as(user)
      visit photos_path
      click_link "Delete"

      expect(page).not_to have_css "img[src*=kitten]"
      expect(page).not_to have_content photo.status
      expect(current_path).to eq photos_path
    end

    context "cannot delete other users' photos" do
      before do
        other_user = FactoryGirl.create(:user)
        sign_in_as(other_user)
      end

      scenario "prevents from deleting other users photos on user interface" do
        visit photos_path
        expect(page).not_to have_link "Delete"
      end

      scenario "prevents from deleting other users photos via a delete request" do
        page.driver.submit :delete, photo_path(photo.id), {}
        expect(current_path).to eq photos_path
        expect(page).to have_content photo.status
      end
    end
  end
end
